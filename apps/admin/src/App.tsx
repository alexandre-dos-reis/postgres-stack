import { Admin, Resource } from "react-admin";
import { authProvider, dataProvider } from "./providers";
import { artworkResource } from "./resources";

const App = () => (
  <Admin authProvider={authProvider} dataProvider={dataProvider}>
    <Resource {...artworkResource} />
  </Admin>
);

export default App;
