import axios from "axios";
import * as helper from "./serviceHelper";

//const endpoint = "https://api.remotebootcamp.dev/api/techcompanies"
const endpoint = "https://localhost:50001/api/techcompanies"

//all service functions follow<Job>

//get entity by id
//done for TechCompanies
const getById = (id) => {

    console.log("Get friend by id is executing");
    const config = {
        method: "GET",
        url: endpoint + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
}

//get entity by id
//done for TechCompanies
const getBySlug = (id) => {

    console.log("Get friend by id is executing");
    const config = {
        method: "GET",
        url: endpoint + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
}

//get all entities
//done for TechCompanies
const getPage = (index, size) => {

    console.log("Get all by entity is executing");
    const config = {
        method: "GET",
        url: endpoint + `/paginate?pageIndex=${index}&pageSize=${size}`,  //hardcoded page zero 10 size
        crossdomain: true,
        withCredentials: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}


//add entity
//done for TechCompanies
const add = (payload) => {

    console.log("Create new job is executing");
    const config = {
        method: "POST",
        url: endpoint,
        data: payload,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);//.then((response) => { return { id: response.data.item, ...payload } });
};

//update entity by id
//done for TechCompanies
const update = (id, payload) => {

    console.log("Update blog is executing " + endpoint + "/" + id);

    if (!id) return;

    const config = {
        method: "PUT",
        url: endpoint + "/" + id,
        data: payload,
        withCredentials: true,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);//.then((response) => { return { id: id, ...payload } });
};


//update entity by id
//done for TechCompanies
const setStatus = (id, status) => {

    console.log("Update blog is executing " + endpoint + "/" + id);

    if (!id) return;

    const config = {
        method: "PUT",
        url: endpoint + "/" + id + "/" + status,
        crossdomain: true,
        withCredentials: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);//.then((response) => { return { id: id } });
};

//get all entities
//done for TechCompanies
const search = (index, size, searchFor) => {

    console.log("Get all by entity is executing");
    const config = {
        method: "GET",
        url: endpoint + `/search?pageIndex=${index}&pageSize=${size}&search=${searchFor}`,  //hardcoded page zero 10 size
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);

}
export { getById, getBySlug, getPage, add, update, setStatus, search };