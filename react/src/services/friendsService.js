//Friends API service functions
//These functions make the API
//calls to the Sabio API page
//
import axios from "axios";
import * as helper from "./serviceHelper";

//const entity = "https://api.remotebootcamp.dev/api/friends"
const entity = "https://localhost:50001/api/v3/friends"

//Get friend by id
//Parameters:
//- id - Friend Id
//
const getById = (id) => {

    const config = {
        method: "GET",
        url: entity + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//Get friend by slug
//Parameters:
//- id - Friend slug
//
const getBySlug = (id) => {

    const config = {
        method: "GET",
        url: entity + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//Get page of friends
//CURRENTLY - hardcoded with an index of 0 and a page size of 10
//
const getPage = (index, size) => {

    const config = {
        method: "GET",
        url: `${entity}/paginate?pageIndex=${index}&pageSize=${size}`,  //hardcoded page zero 10 size
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//Delete friend by Id
//Parameters:
//- id - Friend Id
//
const deleteById = (id) => {

    if (!id) return;
    if (isNaN(id)) return;

    const config = {
        method: "DELETE",
        url: entity + "/" + id,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then((response) => { return { id: id, response: response } });
};

//Add friend
//Parameters:
//- payload - Friend JSON
//
const add = (payload) => {

    const config = {
        method: "POST",
        url: entity,
        data: payload,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);//.then((response) => { return { id: response.item, ...payload } }); //.then(helper.onGlobalSuccess);//.then((response) => { return { id: response.data.item, ...payload } });
};

//Update friend record
//Parameters:
//- id - Friend Id
//- payload - Friend JSON
//
const update = (id, payload) => {

    if (!id) return;

    const config = {
        method: "PUT",
        url: entity + "/" + id,
        data: payload,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);//.then((response) => { return { id: id, ...payload } });
};


//Set friend status
//Parameters:
//- id - Friend Id
//- status - New status
//
const setStatus = (id, status) => {

    if (!id) return;

    const config = {
        method: "PUT",
        url: entity + "/" + id + "/" + status,
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess); //.then((response) => { return { id: id, ...payload } });
};

//Search friend record
//Parameters:
//- searchFor - The text to base the search off of
//
const search = (index, size, searchFor) => {

    const config = {
        method: "GET",
        url: `${entity}/search?pageIndex=${index}&pageSize=${size}&query=${searchFor}`,  //hardcoded page zero 10 size
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config).then(helper.onGlobalSuccess);
}

//Must export to import
//
export { getById, getBySlug, getPage, deleteById, add, update, setStatus, search };

