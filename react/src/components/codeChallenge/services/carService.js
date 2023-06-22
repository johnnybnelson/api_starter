import axios from "axios";

var carService = {
    endpoint: "https://my-json-server.typicode.com/selvaicodes/cars/cars"
};

//Add candidate
//Parameters:
//- payload - candidate JSON
//
carService.getAll = () => {

    const config = {
        method: "GET",
        url: carService.endpoint,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

export default carService
