import axios from "axios";

//const entity = "https://api.remotebootcamp.dev/api/users";
const entity = "https://localhost:50001/api/users";



//register new user
const add = (payload) => {

    console.log("Add new user is executing");
    const config = {
        method: "POST",
        url: entity,
        data: payload,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};


// //get the current logged-in user
const getCurrentUser = () => {

    console.log("Get current user is executing");
    const config = {
        method: "GET",
        url: entity + "/current",
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

// //get user by id
const getUserById = (id) => {

    console.log("Get user by ID is executing");
    const config = {
        method: "GET",
        url: entity + "/" + id,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

// //log out as current user
const logout = () => {

    console.log("Logout is executing");
    const config = {
        method: "GET",
        url: entity + "/logout",
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

// //log in
const login = (payload) => {

    console.log("Login is executing");
    const config = {
        method: "POST",
        url: entity + "/login",
        data: payload,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
};

export { add, getCurrentUser, getUserById, logout, login };



