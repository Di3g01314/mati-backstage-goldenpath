import { createApp } from '@backstage/frontend-defaults';
import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';
import { SignInPage } from '@backstage/core-components';
import { configApiRef, githubAuthApiRef, useApi } from '@backstage/core-plugin-api';
import { navModule } from './nav';
const signIn = createFrontendModule({
  pluginId: 'app',
  extensions: [SignInPageBlueprint.make({params: {loader: async () => props => {
    const config = useApi(configApiRef);
    return <SignInPage {...props} title="Bienvenido a GoldenPath" align="center"
      providers={config.getOptionalBoolean('goldenpath.localMode') ? ['guest'] : [{
        id: 'github-auth-provider', title: 'GitHub', message: 'Ingresa con tu cuenta del equipo piloto', apiRef: githubAuthApiRef,
      }]} />;
  }}})],
});
export default createApp({ features: [signIn, navModule] });
