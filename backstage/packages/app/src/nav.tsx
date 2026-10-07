import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { NavContentBlueprint } from '@backstage/plugin-app-react';
import { Sidebar, SidebarItem, SidebarDivider, SidebarSpace, Link } from '@backstage/core-components';
export const navModule = createFrontendModule({pluginId: 'app', extensions: [NavContentBlueprint.make({
  params: {component: ({navItems}) => <Sidebar>
    <Link to="/" style={{padding: '28px 16px', color: '#68e0cf', fontSize: 21, fontWeight: 800, letterSpacing: '-1px'}}>GoldenPath</Link>
    <SidebarDivider />
    {navItems.withComponent(item => <SidebarItem icon={() => item.icon} to={item.href} text={item.title} />).rest({sortBy: 'title'})}
    <SidebarSpace /><SidebarDivider />
    <div style={{padding: 16, color: '#b6c0d0', fontSize: 12}}>Una idea. Un servicio.<br/>Sin tickets.</div>
  </Sidebar>},
})]});
