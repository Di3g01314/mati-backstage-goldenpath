import {createBackendModule} from '@backstage/backend-plugin-api';
import {policyExtensionPoint} from '@backstage/plugin-permission-node/alpha';
import {AuthorizeResult} from '@backstage/plugin-permission-common';
import type {PermissionPolicy, PolicyQuery, PolicyQueryUser} from '@backstage/plugin-permission-node';
class GoldenPathPolicy implements PermissionPolicy {
  async handle(request: PolicyQuery, user?: PolicyQueryUser) {
    // Catalog registration is performed by the fixed scaffolder action using service credentials.
    // Users cannot import arbitrary templates that would exercise the GitHub integration token.
    if(user && ['catalog.location.create','catalog.location.delete','catalog.entity.delete'].includes(request.permission.name)) {
      return {result: AuthorizeResult.DENY};
    }
    return {result: AuthorizeResult.ALLOW};
  }
}
export const permissionModule=createBackendModule({pluginId:'permission',moduleId:'goldenpath-policy',register(reg){
  reg.registerInit({deps:{policy:policyExtensionPoint},async init({policy}){policy.setPolicy(new GoldenPathPolicy());}});
}});
