import {createBackendModule, coreServices} from '@backstage/backend-plugin-api';
import {createTemplateAction} from '@backstage/plugin-scaffolder-node';
import {scaffolderActionsExtensionPoint} from '@backstage/plugin-scaffolder-node';
import {DefaultGithubCredentialsProvider, ScmIntegrations} from '@backstage/integration';
import {Octokit} from '@octokit/rest';
export const goldenpathModule = createBackendModule({
  pluginId: 'scaffolder', moduleId: 'goldenpath',
  register(reg) {reg.registerInit({deps: {actions: scaffolderActionsExtensionPoint, config: coreServices.rootConfig, auth: coreServices.auth, discovery: coreServices.discovery}, async init({actions,config,auth,discovery}) {
    const credentials = DefaultGithubCredentialsProvider.fromIntegrations(ScmIntegrations.fromConfig(config));
    const owner = config.getString('goldenpath.githubOwner');
    const repo = config.getString('goldenpath.gitopsRepo');
    actions.addActions(createTemplateAction({
      id: 'goldenpath:context', description: 'Valida identidad/equipo y deriva el contrato de plataforma.',
      supportsDryRun: true,
      schema: {
        input: {
          name: z=>z.string().regex(/^[a-z][a-z0-9-]{2,19}$/), team: z=>z.enum(['piloto']),
          size: z=>z.enum(['pequena','mediana']), description: z=>z.string().min(1).max(160).regex(/^[^\n\r]+$/),
        },
        output: {repoName:z=>z.string(),namespace:z=>z.string(),costCenter:z=>z.string(),owner:z=>z.string(),githubOwner:z=>z.string(),gitopsRepo:z=>z.string(),serviceImage:z=>z.string()},
      },
      async handler(ctx) {
        const team = config.getConfig(`goldenpath.teams.${ctx.input.team}`);
        const ref = ctx.user?.ref?.toLowerCase();
        if (!ref || !team.getStringArray('members').map(x=>x.toLowerCase()).includes(ref)) throw new Error('El usuario no pertenece al equipo seleccionado.');
        ctx.output('repoName',`gp-${ctx.input.team}-${ctx.input.name}`);
        for (const key of ['namespace','costCenter','owner'] as const) ctx.output(key,team.getString(key));
        ctx.output('githubOwner',owner);ctx.output('gitopsRepo',repo);ctx.output('serviceImage',config.getString('goldenpath.serviceImage'));
      },
    }));
    actions.addActions(createTemplateAction({
      id:'goldenpath:register',description:'Registra únicamente el repositorio validado del Golden Path.',supportsDryRun:true,
      schema:{input:{repoName:z=>z.string().regex(/^gp-piloto-[a-z][a-z0-9-]{2,19}$/)},output:{entityRef:z=>z.string()}},
      async handler(ctx){
        const members=config.getStringArray('goldenpath.teams.piloto.members');
        if(!ctx.user?.ref || !members.map(x=>x.toLowerCase()).includes(ctx.user.ref.toLowerCase())) throw new Error('Usuario no autorizado.');
        if(!ctx.isDryRun){
          if(config.getOptionalBoolean('goldenpath.localMode')) throw new Error('El modo local no registra repositorios remotos.');
          const {token}=await auth.getPluginRequestToken({onBehalfOf:await auth.getOwnServiceCredentials(),targetPluginId:'catalog'});
          const response=await fetch(`${await discovery.getBaseUrl('catalog')}/locations`,{method:'POST',headers:{'Content-Type':'application/json',Authorization:`Bearer ${token}`},body:JSON.stringify({type:'url',target:`https://github.com/${owner}/${ctx.input.repoName}/blob/main/catalog-info.yaml`})});
          if(!response.ok && response.status!==409) throw new Error(`No se pudo registrar el servicio: ${response.status}`);
        }
        ctx.output('entityRef',`component:default/${ctx.input.repoName}`);
      },
    }));
    actions.addActions(createTemplateAction({
      id:'goldenpath:merge',description:'Fusiona exclusivamente el PR generado cuando la política pasa para su SHA.',
      schema:{input:{pullRequest:z=>z.number().int().positive(),repoName:z=>z.string().regex(/^gp-piloto-[a-z][a-z0-9-]{2,19}$/)}},
      async handler(ctx) {
        if(config.getOptionalBoolean('goldenpath.localMode')) throw new Error('El modo local no modifica GitHub.');
        const members=config.getStringArray('goldenpath.teams.piloto.members');
        if(!ctx.user?.ref || !members.map(x=>x.toLowerCase()).includes(ctx.user.ref.toLowerCase())) throw new Error('Usuario no autorizado.');
        const {token}=await credentials.getCredentials({url:`https://github.com/${owner}/${repo}`});
        const octokit=new Octokit({auth:token});
        for(let attempt=0;attempt<60;attempt++) {
          if(ctx.signal?.aborted) throw new Error('Solicitud cancelada.');
          const {data:pr}=await octokit.pulls.get({owner,repo,pull_number:ctx.input.pullRequest});
          if(pr.head.ref!==`goldenpath/${ctx.input.repoName}` || pr.head.repo?.full_name!==`${owner}/${repo}` || pr.base.ref!=='main') throw new Error('El PR no corresponde al Golden Path.');
          if(pr.merged) return;
          if(pr.state!=='open') throw new Error('El PR fue cerrado.');
          const {data:checks}=await octokit.checks.listForRef({owner,repo,ref:pr.head.sha,per_page:100});
          const policy=checks.check_runs.find(check=>check.name==='goldenpath-policy' && check.app?.slug==='github-actions');
          if(policy?.conclusion==='success') {
            const result=await octokit.pulls.merge({owner,repo,pull_number:pr.number,sha:pr.head.sha,merge_method:'squash'});
            if(!result.data.merged) throw new Error('GitHub no permitió fusionar el PR.');
            return;
          }
          if(policy?.status==='completed') throw new Error('La política rechazó la solicitud. Revisa el PR.');
          await new Promise(resolve=>setTimeout(resolve,10000));
        }
        throw new Error('La validación sigue pendiente. El PR se conserva; no se creó infraestructura fuera de Git.');
      },
    }));
  }});},
});
