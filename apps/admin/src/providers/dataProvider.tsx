import postgrestRestProvider, {
  defaultPrimaryKeys,
} from "@raphiniert/ra-data-postgrest";
import { fetchUtils } from "react-admin";

const httpClient = (
  url: string,
  options: { user: { authenticated: boolean; token: string } },
) => {
  const token = localStorage.getItem("auth-token");
  if (token) {
    options.user = {
      authenticated: true,
      token: `Bearer ${token}`,
    };
  }
  return fetchUtils.fetchJson(url, options);
};

export const dataProvider = postgrestRestProvider({
  apiUrl: import.meta.env.VITE_PGRST_URL,
  httpClient,
  defaultListOp: "eq",
  primaryKeys: defaultPrimaryKeys,
  schema: () => "app_admin",
});
