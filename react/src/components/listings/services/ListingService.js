import axios from "axios";

var listingService = {
    endpoint: "https://api.remotebootcamp.dev/api/entities/presidents"
};


listingService.add = (payload) => {

    const config = {
        method: "POST",
        url: listingService.endpoint,
        data: payload,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

listingService.get = () => {

    const config = {
        method: "GET",
        url: listingService.endpoint,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

export default listingService