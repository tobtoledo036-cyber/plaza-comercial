import axios from "axios";

const api = axios.create({
  baseURL: "https://plazas-backend.grayflower-9f85bbb5.eastus.azurecontainerapps.io"
});

export default api;