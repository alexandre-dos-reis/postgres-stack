import "swagger-ui/dist/swagger-ui.css";
import SwaggerUI from "swagger-ui";

const ui = SwaggerUI({
  dom_id: "#app",
  url: `http://localhost:${import.meta.env.VITE_OPENAPI_API_PORT}`,
  deepLinking: true,
  responseInterceptor: (res) => {
    // https://github.com/swagger-api/swagger-ui/issues/4382#issuecomment-434673920
    console.log(res);
    if (res.obj.access_token) {
      const token = res.obj.access_token;
      ui.preauthorizeApiKey("AccessToken", token);
    }
    return res;
  },
});
