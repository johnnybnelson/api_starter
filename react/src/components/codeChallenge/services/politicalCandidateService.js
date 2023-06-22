import axios from "axios";

var politicalCandidateService = {
    endpoint: "https://api.remotebootcamp.dev/api/entities/candidates"
};

//Add candidate
//Parameters:
//- payload - candidate JSON
//
politicalCandidateService.add = (payload) => {

    const config = {
        method: "POST",
        url: politicalCandidateService.endpoint,
        data: payload,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);//.then((response) => { return { id: response.item, ...payload } }); //.then(helper.onGlobalSuccess);//.then((response) => { return { id: response.data.item, ...payload } });
};

export default politicalCandidateService
