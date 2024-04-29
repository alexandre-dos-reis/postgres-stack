import "swagger-ui/dist/swagger-ui.css";
import SwaggerUI from "swagger-ui";

SwaggerUI({
  dom_id: "#app",
  url: `http://localhost:${import.meta.env.VITE_OPENAPI_API_PORT}`,
});
