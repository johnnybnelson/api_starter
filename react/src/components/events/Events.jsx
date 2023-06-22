import React, { useState, useEffect } from "react";
import * as eventsService from "../../services/eventsService";
import Pagination from 'rc-pagination';
import 'rc-pagination/assets/index.css';
import locale from "rc-pagination/lib/locale/en_US";  //pass as prop to pagination component
import { Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';
//import { Autocomplete } from '@react-google-maps/api';
import { GoogleMap, LoadScript, Marker, Autocomplete } from '@react-google-maps/api';
import Geocode from "react-geocode";
import Event from "./Event";
//import ReactHtmlParser from 'react-html-parser';
//import parse from 'html-react-parser';

//import * as usersService from "../../services/usersService";
//import { useNavigate } from "react-router-dom";
import Toastr from "toastr";

//This one is for tabs
//
import {
  TabContent, TabPane, Nav,
  NavItem, NavLink, Row, Col
} from 'reactstrap';
import classnames from "classnames";

//this is for Google maps
//
const containerStyle = {
  width: '100%',
  height: '400px'
};


function Events() {


  // set Google Maps Geocoding API for obtaining the lat/lng
  //based on address
  //
  Geocode.setApiKey("AIzaSyCmpmDVRALSWSKAeTdrEzX8cKmUMRMf4yY");

  // set response language. Defaults to english.
  //
  Geocode.setLanguage("en");

  //state for Google maps lat/lng obtained
  //via Geocode
  //
  const [loc, setLoc] = useState({
    lat: -3.745,
    lng: -38.523,
    eventMapMarkers: [],
    showAllMapMarkers: false,
    locs: []
  });
  console.log(loc);

  //Sets the loc state, which will render
  //the map for that location
  //
  const goToLocation = (lat, lng) => {
    setLoc(() => {
      return { "lat": lat, "lng": lng, eventMapMarkers: loc.eventMapMarkers, showAllMapMarkers: loc.showAllMapMarkers, locs: loc.locs };
    })
    //MAP2
    // let newCoords = { lat: lat, lng: lng };
    // map.setOptions({
    //   center: newCoords,
    //   zoom: 2
    // });
    // setMap(map);
    // addMarker(lat, lng);
  }

  //const [map, setMap] = useState(null);


  //modal window state
  //modal will toggle true/false
  //true - window shows
  //false - window doesn't show
  //
  const [modal, setModal] = useState(false);

  //newEvent state for creating a new event
  //
  const [newEvent, setNewEvent] = useState({

    "name": "",
    "description": "",
    "summary": "",
    "headline": "",
    "slug": "",
    "statusId": "",
    "zipCode": "",
    "address": "",
    "latitude": 0,
    "longitude": 0,
    "dateStart": "",
    "dateEnd": "",
    "id": 0

  });
  console.log("newEvent", newEvent);




  //invoked by clicking cancel on the 
  //new event modal
  //
  const clearNewEvent = (e) => {
    toggleModal(e);
    emptyTheNewPayload();
  }

  //empty the payload state for new event
  //This is to clear after a cancel on the
  //new event modal, and also after a new 
  //record is created
  //
  const emptyTheNewPayload = () => {
    setNewEvent(() => {
      return {
        "dateStart": "",
        "dateEnd": "",
        "latitude": 0,
        "longitude": 0,
        "zipCode": "",
        "address": "",
        "name": "",
        "headline": "",
        "description": "",
        "summary": "",
        "slug": "",
        "statusId": "Active"
      };
    })
  }

  // State for current active feed of events
  // events - array of events from the Sabio API
  // eventComponents - array of HTML components
  //            generated from the array of events
  // selectedIndex - Which of the events in the list
  //            will be displayed
  //
  const [pageData, setPage] = useState({
    events: [],
    eventComponents: [],
    currentTab: "1",
    type: "EVENTS_VIEW",
    selectedIndex: 0,
    pageIndex: 0,
    pageSize: 3,
    totalCount: 0,
    totalPages: 0
  });
  console.log(pageData);

  //toggleModal function, which sets te state
  //
  const toggleModal = (e) => {
    e.preventDefault();
    setModal(!modal);
  }

  const showPagedMapMarkers = (e) => {
    e.preventDefault();
    if (Number(pageData.currentTab) !== 2) tabToggle("2");
    setLoc((prevLoc) => {
      let newObj = JSON.parse(JSON.stringify(prevLoc));
      newObj.showAllMapMarkers = (!newObj.showAllMapMarkers);

      // for (let index = 0; index < newObj.eventMapMarkers.length; index++) {  MAP2
      //   //const element = array[index];
      //   addMarker(newObj.eventMapMarkers[index].lat, newObj.eventMapMarkers[index].lng);
      // }

      return newObj;
    })
  }


  //CREATE NEW EVENT BEGIN
  //invoked on the Create New button
  //to create the new event record
  //
  const onCreateNew = (e) => {
    e.preventDefault();
    console.log("onCreateNew", e);

    if ((newEvent.name.length < 3) || (newEvent.name.length > 25)) {
      Toastr.warning("Name must be between three and 25 characters in length!")
      return false;
    }

    if ((newEvent.headline.length < 3) || (newEvent.headline.length > 80)) {
      Toastr.warning("Image URL must be between three and 80 characters in length!")
      return false;
    }

    eventsService
      .add(newEvent)
      .then(createSuccess)
      .catch(createError);
  }

  const createSuccess = (response) => {
    console.log("createSuccess", response);
    Toastr.success("Record created successfully!");
    loadEvents();
    emptyTheNewPayload();
    setModal(!modal);
  }

  const createError = (err) => {
    console.log("getError", err);
    emptyTheNewPayload();
    Toastr.error("Record not created!");
  }
  //CREATE NEW EVENT END

  //GET EVENTS FEED BEGIN
  //Load events (feed) based on pageIndex and pageSize
  //
  const loadEvents = () => {
    eventsService
      .getFeed(pageData.pageIndex, pageData.pageSize)
      .then(getSuccess)
      .catch(getError)
  }

  const getSuccess = (response) => {
    console.log("getSuccess", response)

    setPage((prevState) => {

      let tempObj = { ...prevState };

      tempObj.events = response.data.item.pagedItems;
      tempObj.eventComponents = tempObj.events.map(buildEventList);
      tempObj.pageIndex = response.data.item.pageIndex;
      tempObj.pageSize = response.data.item.pageSize;
      tempObj.totalCount = response.data.item.totalCount;
      tempObj.totalPages = response.data.item.totalPages;
      return tempObj;

    })
  }
  const getError = (err) => {
    console.log("getError", err)
    Toastr.error(err);
  }
  //GET EVENTS FEED END

  //Change which event is the primary event on
  //the left of the screen
  //
  const changePrimaryView = (index) => {
    setPage((prevPage) => {
      let newObj = { ...prevPage };
      newObj.selectedIndex = index;
      newObj.showAllMapMarkers = false;
      return newObj;
    });
    tabToggle("1");
    //    turnOffPagedMapMarkers();
  }

  //mapping function to create an event card
  //for every event on the "get"
  //
  const buildEventList = (event, index) => {

    //get the address of the selected event and get the lat/lng
    Geocode.fromAddress(event.address + ", " + event.zipCode)
      .then(
        (response) => {
          const { lat, lng } = response.results[0].geometry.location;
          console.log(lat, lng);
          setNewMarker(lat, lng);//`<Marker position={{ lat: ${lat}, lng: ${lng} }} />`);
        },
        (error) => {
          console.error(error);
        }
      ).catch(err => {
        console.log(err);
      });

    let anObj = { ...event };
    return <Event changePrimaryView={changePrimaryView}
      eventIndex={index}
      key={anObj.id}
      anEvent={anObj}
      addEditEvent={editHolder}
      formFieldChange={onFormFieldChange}>
    </Event>
  }

  const setNewMarker = (lat, lng) => {
    setLoc((prevLoc) => {
      let newObj = JSON.parse(JSON.stringify(prevLoc));
      newObj.eventMapMarkers.push(`<Marker position={{ lat: ${lat}, lng: ${lng} }} />`);
      newObj.locs.push({ lat: lat, lng: lng });
      return newObj;
    });
  }

  // const buildMarkerList = (eventArray) => {

  //   //get the address of the selected event and get the lat/lng
  //   Geocode.fromAddress(eventArray.metaData.location.address + ", " + eventArray.metaData.location.zipCode)
  //     .then(
  //       (response) => {
  //         const { lat, lng } = response.results[0].geometry.location;
  //         console.log(lat, lng);
  //         //return `<Marker position={{ lat: ${lat}, lng: ${lng} }} />`;
  //         setNewMarker(`<Marker position={{ lat: ${lat}, lng: ${lng} }} />`);
  //       },
  //       (error) => {
  //         console.error(error);
  //       }
  //     ).catch(err => {
  //       console.log(err);
  //     });
  //   return "No lat/lng found";
  // }

  //edit the state record for the successfully-edited 
  //corresponding database record
  //
  const editHolder = (updatedEvent, index) => {
    console.log("editHolder", index, updatedEvent)

    setPage((prevPage) => {

      let newObj = { ...prevPage };
      let newEvent = { ...prevPage.events[index] };
      //let newMetaLoc = { ...prevPage.events[index].location };
      //let newTime = { ...prevPage.events[index].metaData }

      newEvent = updatedEvent;
      //newMetaLoc = updatedEvent.metaData.location;
      //newTime = updatedEvent.metaData;

      newObj.events[index] = newEvent;
      //newObj.events[index].metaData = newTime;
      //newObj.events[index].metaData.location = newMetaLoc;

      return newObj;
    })

  }


  //update the state with changes to add new 
  //event form elements
  //
  const onFormFieldChange = (e) => {   //captures this event

    //const eventIndex = e.currentTarget.dataset.index;

    //Assign the target of the event to the target variable
    //
    const target = e.target;

    //This is the value to update the state with
    //
    const value = target.value;

    //This is the name of the target. Your HTML elements
    //MUST have the name property set for this to work.
    //
    const name = target.name;

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setNewEvent((prevNewEvent) => {

      // copy the previous state
      //
      let newUserEvents =
        JSON.parse(JSON.stringify(prevNewEvent));

      // change the value of the copied object using the name and using bracket notation
      // ONE conditional is the image, which doesn't sit at the same level with the other 
      // properties of the JSON

      // if (name === "dateStart") {
      //   newUserEvents.metaData.dateStart = value;  //  <- bracket notation!!!!
      // } else if (name === "dateEnd") {
      //   newUserEvents.metaData.dateEnd = value;  //  <- bracket notation!!!!
      // } else if (name === "address") {
      //   newUserEvents.metaData.location.address = value;  //  <- bracket notation!!!!
      // } else if (name === "zipCode") {
      //   newUserEvents.metaData.location.zipCode = value;  //  <- bracket notation!!!!
      // }
      // else {
      newUserEvents[name] = value;  //  <- bracket notation!!!!
      //}
      return newUserEvents;
    });
  };


  // Toggle active state for tabs
  //
  const tabToggle = tab => {
    //if clicking on tab 2, display the map
    if (Number(tab) === 2) startMapping();
    if (pageData.currentTab !== tab) setPage((prevState) => {
      let newObj = { ...prevState };
      newObj.currentTab = tab;
      return newObj;
    });
  }

  //When the page navigation
  //is clicked
  //
  const onPageChange = page => {
    console.log("onChange", page);

    tabToggle("1"); //reset tab to first tab

    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.pageIndex = page - 1;
      pageDataComp.selectedIndex = 0;
      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };

  //set the map state lat/lng
  //
  const startMapping = () => {

    //if there is actually a record in state
    if (pageData.events.length > 0) {

      //get the address of the selected event and get the lat/lng
      Geocode.fromAddress(pageData.events[pageData.selectedIndex].address + ", " + pageData.events[pageData.selectedIndex].zipCode).then(
        (response) => {
          const { lat, lng } = response.results[0].geometry.location;
          console.log(lat, lng);
          goToLocation(lat, lng);
        },
        (error) => {
          console.error(error);
        }
      );
    };
  }

  // this is invoked following successful mount
  // 
  useEffect(() => {

    loadEvents();

    // var map = new window.google.maps.Map(document.getElementById('map'), {
    //   center: { lat: 37.7749, lng: -122.4194 },
    //   zoom: 8,
    // });
    // setMap(map);  MAP2


  }, [pageData.pageIndex, pageData.selectedIndex, pageData.currentTab]   //removed 
  );

  //AUTOCOMPLETE CODE BEGIN
  //
  const [autocomplete, setAutocomplete] = useState(null);
  console.log("autocomplete", autocomplete);

  const onLoad = (autocomplete) => {
    console.log('autocomplete: ', autocomplete)

    setAutocomplete(autocomplete)
  }

  const onPlaceChanged = () => {
    // if (autocomplete !== null) {
    //     console.log(this.autocomplete.getplace())
    // } else {
    //     console.log('autocomplete is not loaded yet!')
    // }
    console.log("place Changed")
  }
  //
  //AUTOCOMPLETE CODE END
  //

  // const addMarker = (lat, lng) => { MAP2
  // const addMarker = (lat, lng) => {
  //     new window.google.maps.Marker({
  //     position: { lat, lng },
  //     map,
  //   });
  // }

  return (
    <React.Fragment>

      <div className="container">
        <div className="row">


          {/* TABS BEGIN */}
          <Nav tabs>
            <NavItem>
              <NavLink
                className={classnames({
                  active:
                    pageData.currentTab === '1'
                })}
                onClick={() => { tabToggle('1'); }}
              >
                Event
              </NavLink>
            </NavItem>
            <NavItem>
              <NavLink
                className={classnames({
                  active:
                    pageData.currentTab === '2'
                })}
                onClick={() => { tabToggle('2'); }}
              >
                Event Map View
              </NavLink>
            </NavItem>
          </Nav>
          <TabContent activeTab={pageData.currentTab} className="col-8">
            <TabPane tabId="1">
              <Row>
                <Col sm="12">
                  <div className="">
                    <div className="card">
                      <h2 className="card-title px-2" id="currentName">{(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].name : ""}</h2>
                      <img style={{ height: "400px", objectFit: "contain" }} id="currentImage" className="card-img" src={(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].headline : ""} alt=""></img>
                      <p>
                        <div className="row">
                          <div className="col-12">
                            <h5 className="card-title px-2 mt-4">Location</h5>
                            <table><tr><td className="px-4 h6">
                              <p className="card-text mb-0 h6" id="currentAddress">{(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].address : ""}</p>
                            </td><td>
                                <p className="card-text mb-0" id="currentStartDate"><table><tr><td className="h6" style={{ width: "50px" }}>From:</td><td> {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].dateStart.substring(0, 9) : ""}</td></tr></table></p>
                              </td></tr>
                              <tr><td className="px-4 h6">
                                <p className="card-text mb-0 h6" id="currentAddress">{(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].zipCode : ""}</p>
                              </td>
                                <td>
                                  <p className="card-text mb-0" id="currentStartEnd"><table><tr><td className="h6" style={{ width: "50px" }}>To:</td><td> {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].dateEnd.substring(0, 9) : ""}</td></tr></table></p>
                                </td></tr>
                            </table>
                          </div>
                        </div>
                      </p>
                      <p className="card-text p-2" id=""><p className="h5">Summary</p> {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].summary : ""}</p>
                      <p className="card-text p-2" id="currentDescription"><p className="h5">Description</p>
                        {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].description : ""}
                      </p>
                    </div>
                  </div>




                </Col>
              </Row>
            </TabPane>
            <TabPane tabId="2">
              <Row>
                <Col sm="12">
                  <div className="">
                    <div className="card">
                      {/* <img className="card-img-top" src="https://cdn.wccftech.com/wp-content/uploads/2017/03/Google-Maps.jpg" alt="Google Maps" /> */}
                      <h2 className="card-title px-2" id="currentName">{(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].name : ""}</h2>
                      <LoadScript
                        googleMapsApiKey="AIzaSyCmpmDVRALSWSKAeTdrEzX8cKmUMRMf4yY"
                        libraries={["places"]}>
                        <GoogleMap
                          style={{ width: "100%" }}
                          mapContainerStyle={containerStyle}
                          center={loc}
                          zoom={loc.showAllMapMarkers ? 5 : 15}
                        //onLoad={generateMarkers}
                        // dangerouslySetInnerHTML={{ __html: loc.showAllMapMarkers ? loc.eventMapMarkers.join("") : "" }}
                        // dangerouslySetInnerHTML={{ __html: loc.showAllMapMarkers ? <Marker position={{ lat: 100, lng: 100 }} /> : "" }}
                        >
                          { /* Child components, such as markers, info windows, etc. */}
                          <></>
                          {/* {loc.showAllMapMarkers ? <Marker position={{ lat: 100, lng: 100 }} /> : ""} */}
                          {/* ReactHtmlParser(loc.eventMapMarkers.join("")) : ""} */}
                          <Marker
                            position={loc}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 0 ? loc.locs[0] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 1 ? loc.locs[1] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 2 ? loc.locs[2] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 3 ? loc.locs[3] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 4 ? loc.locs[4] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 5 ? loc.locs[5] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 6 ? loc.locs[6] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 7 ? loc.locs[7] : null) : null}
                          />
                          <Marker
                            position={loc.showAllMapMarkers ? (loc.locs.length > 8 ? loc.locs[8] : null) : null}
                          />
                        </GoogleMap>
                      </LoadScript>
                      {/* <div id="map" style={{ height: '500px' }}>MAP?</div> MAP2 */}
                      <p>
                        <div className="row">
                          <div className="col-12">
                            <h5 className="card-title px-2 mt-4">Location</h5>
                            <table><tr><td className="px-4 h6">
                              <p className="card-text mb-0 h6" id="currentAddress">{(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].address : ""}</p>
                            </td><td>
                                <p className="card-text mb-0" id="currentStartDate"><table><tr><td className="h6" style={{ width: "50px" }}>From:</td><td> {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].dateStart.substring(0, 9) : ""}</td></tr></table></p>
                              </td></tr>
                              <tr><td className="px-4 h6">
                                <p className="card-text mb-0 h6" id="currentAddress">{(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].zipCode : ""}</p>
                              </td>
                                <td>
                                  <p className="card-text mb-0" id="currentStartEnd"><table><tr><td className="h6" style={{ width: "50px" }}>To:</td><td> {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].dateEnd.substring(0, 9) : ""}</td></tr></table></p>
                                </td></tr>
                            </table>
                          </div>
                        </div>
                      </p>
                      <p className="card-text p-2" id=""><p className="h5">Summary</p> {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].summary : ""}</p>
                      <p className="card-text p-2" id="currentDescription"><p className="h5">Description</p>
                        {(pageData.events.length > 0) ? pageData.events[pageData.selectedIndex].description : ""}
                      </p>
                    </div>
                  </div>
                </Col>
              </Row>
            </TabPane>

          </TabContent>
          {/* TABS END */}

          <div className="col-4">
            <div className="card">
              <div className="card-body overflow-auto" style={{ maxHeight: "700px" }} >
                <small>
                  <nav aria-label="Page navigation example">
                    <Pagination
                      onChange={onPageChange}
                      current={pageData.pageIndex + 1}
                      total={pageData.totalCount}
                      locale={locale}
                      pageSize={pageData.pageSize}
                    ></Pagination>
                  </nav>
                </small>

                <Button color="primary" onClick={toggleModal} className="m-3">New Event</Button>
                <Button color="secondary" onClick={showPagedMapMarkers} className={(Number(pageData.currentTab) === 2) ? "m-3" : "d-none"}>{loc.showAllMapMarkers ? "Hide All But Selected" : "View All on Map"}</Button>
                <table className="table table-striped" id="eventsTable">

                  {(pageData.events.length > 0) ? pageData.eventComponents : "No Events Listed"}

                </table>



              </div>
            </div>

          </div>

        </div>
      </div>


      {/* MODAL BEGIN */}
      <Modal isOpen={modal} toggle={toggleModal} >
        <ModalHeader toggle={toggleModal}><b><u>PLACEHOLDER</u></b></ModalHeader>
        <ModalBody>
          <div className="App">
            <table className="table">
              <tr><td>
                <h6>Enter date range</h6>
                <input id="dateStart_New" name="dateStart" className="form-control mb-1" type="datetime-local" onChange={onFormFieldChange} />
                <input id="dateEnd_New" name="dateEnd" className="form-control mb-1" type="datetime-local" onChange={onFormFieldChange} />

              </td></tr>
              <tr><td className="h6">
                Title

                <input type="text" id="name_New" name="name" className="form-control" onChange={onFormFieldChange} />
              </td></tr>
              <tr><td className="h6">

                Image
                <input type="text" id="name_New" name="headline" className="form-control" onChange={onFormFieldChange} />
              </td></tr>
              <tr><td className="h6">
                Description

                <input type="text" id="description_New" name="description" className="form-control" onChange={onFormFieldChange} />
              </td></tr>
              <tr><td className="h6">
                Summary

                <input type="text" id="summary_New" name="summary" className="form-control" onChange={onFormFieldChange} />
              </td></tr>
              <tr><td className="h6">
                Slug

                <input type="text" id="slug_New" name="slug" className="form-control" onChange={onFormFieldChange} />
              </td></tr>
              <tr><td className="h6">
                Status

                <select id="statusId_New" name="statusId" onChange={onFormFieldChange} className="form-select">
                  <option value="">Select a status</option>
                  <option value="Active">Active</option>
                  <option value="NotSet">No status</option>
                  <option value="Deleted">Deleted</option>
                  <option value="Flagged">Flagged</option>
                </select>
              </td></tr>
              <tr><td className="h6">
                Address

                <Autocomplete
                  onLoad={onLoad}
                  onPlaceChanged={onPlaceChanged}
                >
                  <input type="text" id="address_New" name="address" className="form-control" onBlur={onFormFieldChange} onChange={onFormFieldChange} />
                </Autocomplete>
                {/* <input type="text" id="address_New" name="address" className="form-control" onChange={onFormFieldChange} /> */}
              </td></tr>
              <tr><td className="h6">
                Zip Code
                <input type="text" id="zipCode_New" name="zipCode" className="form-control" onChange={onFormFieldChange} />
              </td></tr>

            </table>
          </div>
        </ModalBody>
        <ModalFooter>
          <Button color="Save" id="create" name="create" className="btn-primary" onClick={onCreateNew}>
            Create
          </Button>{' '}
          <Button color="secondary" className="btn-info" onClick={clearNewEvent}>
            Cancel
          </Button>
        </ModalFooter>
      </Modal>
      {/* MODAL END */}

      {/* <Navigate></Navigate> */}
    </React.Fragment >
  );
}

export default Events;
