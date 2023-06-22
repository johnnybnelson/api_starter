import axios from "axios";

//const endpoint = "https://api.remotebootcamp.dev/api/files";
const endpoint = "https://localhost:50001/api/files";


//all service functions follow

//get entity by id
//done for events
const uploadFile = (payload) => {

    console.log("uploading file");
    const config = {
        method: "POST",
        url: endpoint,
        data: payload,
        crossdomain: true,
        headers: { "Content-Type": "multipart/form-data" }
    };
    return axios(config); //.then((response) => { return { id: response.data.item, ...payload } });

}

export { uploadFile };
