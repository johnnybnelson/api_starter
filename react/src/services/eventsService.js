import axios from "axios";

//create the entitiesService object

//const endpoint = "https://api.remotebootcamp.dev/api/events"
const endpoint = "https://localhost:50001/api/events"


//all service functions follow

//get entity by id
//done for events
// const getById = (id) => {

//     console.log("Get friend by id is executing");
//     const config = {
//         method: "GET",
//         url: endpoint + "/" + id,
//         crossdomain: true,
//         headers: { "Content-Type": "application/json" }
//     };
//     return axios(config);
// }

//get entity by id
//done for events
// const getBySlug = (id) => {

//     console.log("Get friend by id is executing");
//     const config = {
//         method: "GET",
//         url: endpoint + "/" + id,
//         crossdomain: true,
//         headers: { "Content-Type": "application/json" }
//     };
//     return axios(config);
// }

//get all entities
//done for events
const getFeed = (index, size) => {

    console.log("Get page of events is executing");
    const config = {
        method: "GET",
        url: endpoint + `?pageIndex=${index}&pageSize=${size}`,  //hardcoded page zero 10 size
        crossdomain: true,
        headers: { "Content-Type": "application/json" }
    };
    return axios(config);
}

//add entity
//done for events
const add = (payload) => {

    console.log("Create new event is executing");
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
//done for events
//may need to curry status!!!!!!
//
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
    return axios(config); //.then((response) => { return { id: id, index: index, status: status, ...payload } });
};


//update entity by id
//done for events
// const setStatus = (id, status) => {

//     console.log("Update blog is executing " + endpoint + "/" + id);

//     if (!id) return;

//     const config = {
//         method: "PUT",
//         url: endpoint + "/" + id + "/" + status,
//         crossdomain: true,
//         headers: { "Content-Type": "application/json" }
//     };
//     return axios(config); //.then((response) => { return { id: id } });
// };

//get all entities
//done for events
// const search = (index, size, searchFor) => {

//     console.log("Get all by entity is executing");
//     const config = {
//         method: "GET",
//         url: endpoint + `/search??pageIndex=${index}&pageSize=${size}&q=${searchFor}`,  //hardcoded page zero 10 size
//         crossdomain: true,
//         headers: { "Content-Type": "application/json" }
//     };
//     return axios(config);
// }

//export { getById, getBySlug, add, update, setStatus, search, getFeed };
export { add, update, getFeed };


