//Friends API service functions
//These functions make the API
//calls to the Sabio API pagestate
//
import axios from "axios";
import * as helper from "./serviceHelper";

//const endpoint = "https://api.remotebootcamp.dev/api/jobs"
const endpoint = "https://localhost:50001/api/jobs"

//init the entity type
//will be set on startup
//entityType = "";

//all service functions follow

//get entity by id
//done for Jobs
const getById = (id) => {

    console.log("Get friend by id is executing");
    const config = {
        method: "GET",
        url: endpoint + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//get entity by id
//done for Jobs
const getBySlug = (id) => {

    console.log("Get friend by id is executing");
    const config = {
        method: "GET",
        url: endpoint + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//get all entities
//done for Jobs
const getPage = (index, size) => {

    console.log("Get all by entity is executing");
    const config = {
        method: "GET",
        url: endpoint + `/paginate?pageIndex=${index}&pageSize=${size}`,  //hardcoded page zero 10 size
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//add entity
//done for Jobs
const add = (payload) => {

    console.log("Create new job is executing");
    const config = {
        method: "POST",
        url: endpoint,
        data: payload,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config); //.then((response) => { return { id: response.data.item, ...payload } });
};

//update entity by id
//done for Jobs
const update = (id, payload) => {

    console.log("Update blog is executing " + endpoint + "/" + id);

    if (!id) return;

    const config = {
        method: "PUT",
        url: endpoint + "/" + id,
        data: payload,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);//.then((response) => { return { id: id, ...payload } });
};

//update entity by id
//done for Jobs
const setStatus = (id, status) => {

    //console.log("Update blog is executing " + endpoint + "/" + id);

    if (!id) return;

    const config = {
        method: "PUT",
        url: endpoint + "/" + id + "/" + status,
        crossdomain: true,
        withCredentials: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);//.then(helper.onGlobalSuccess);//.then((response) => { return { id: id } });
};

//get all entities
//done for Jobs
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


