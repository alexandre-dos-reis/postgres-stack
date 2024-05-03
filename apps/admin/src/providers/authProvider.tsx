import { AuthProvider } from "react-admin";

export const authProvider: AuthProvider = {
  login: ({ username, password }: { username: string; password: string }) => {
    const request = new Request(`${import.meta.env.VITE_PGRST_URL}/rpc/login`, {
      method: "POST",
      body: JSON.stringify({ email: username, pass: password }),
      headers: new Headers({ "Content-Type": "application/json" }),
    });

    return fetch(request)
      .then((res) => {
        if (res.status < 200 || res.status >= 300) {
          throw new Error(res.statusText);
        }
        return res.json();
      })
      .then((auth) => {
        localStorage.setItem("auth-token", auth.token);
      })
      .catch(() => {
        throw new Error("Network error");
      });
  },
  logout: () => {
    localStorage.removeItem("auth-token");
    return Promise.resolve();
  },
  checkAuth: () =>
    localStorage.getItem("auth-token") ? Promise.resolve() : Promise.reject(),
  checkError: (error) => {
    const status = error.status;
    if (status === 401 || status === 403) {
      localStorage.removeItem("auth-token");
      return Promise.reject();
    }
    // other error code (404, 500, etc): no need to log out
    return Promise.resolve();
  },
  getIdentity: () => {
    try {
      // const { id, fullName, avatar } = JSON.parse(
      //   localStorage.getItem("auth-token"),
      // );
      return Promise.resolve({ id: "ok", fullName: "ok", avatar: "ok" });
    } catch (error) {
      return Promise.reject(error);
    }
  },
  getPermissions: () => Promise.resolve(),
};
