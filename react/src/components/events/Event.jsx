//This event functional component displays just
//one card per events record. It receives a single
//event object from the array of events in the
//state of the parent component.
//                      
//There are also two local click handlers, 
//one for delete and one for edit, which
//call to the parent functions defined in 
//the properties.
//
import React, { useState } from "react";
import * as eventsService from "../../services/eventsService";
import Toastr from "toastr";
import { Autocomplete } from '@react-google-maps/api';
import { Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';

function Event(props) {

    //states
    //
    const [modal, setModal] = useState(false);
    const [event, setEvent] = useState(JSON.parse(JSON.stringify(props.anEvent)));
    const [holder, setHolder] = useState(JSON.parse(JSON.stringify(props.anEvent)));
    const [modify, setModify] = useState(JSON.parse(JSON.stringify(props.anEvent)));

    //gets the payload JSON of the event record passed
    //
    const getEventUpdatePayload = (anEvent) => {
        return {
            "id": anEvent.id,
            "dateStart": anEvent.dateStart,
            "dateEnd": anEvent.dateEnd,
            "latitude": anEvent.latitude,
            "longitude": anEvent.latitude,
            "zipCode": anEvent.zipCode,
            "address": anEvent.address,
            "name": anEvent.name,
            "headline": anEvent.headline,
            "description": anEvent.description,
            "summary": anEvent.summary,
            "slug": anEvent.slug,
            "statusId": anEvent.statusId
        }
    }

    //toggle function, which sets the state
    //for the modal
    //
    const toggle = (e) => {
        cancelEdit(e);
        setModal(!modal);
    }

    //SAVE BEGIN
    //invoked when "save" is clicked
    //for an event record
    //
    const onLocalEventModify = (e) => {
        e.preventDefault()

        if ((modify.name.length < 3) || (modify.name.length > 25)) {
            Toastr.warning("Name must be between three and 25 characters in length!")
            return false;
        }

        if ((modify.headline.length < 3) || (modify.headline.length > 128)) {
            Toastr.warning("Image URL must be between three and 128 characters in length!")
            return false;
        }

        eventsService
            .update(modify.id, getEventUpdatePayload(modify))
            .then(updateSuccess)
            .catch(updateError);
    }

    const updateSuccess = (response) => {
        console.log(response);
        Toastr.success("Record Saved!");
        setEvent(() => { return (JSON.parse(JSON.stringify(modify))) });
        setHolder(() => { return (JSON.parse(JSON.stringify(modify))) });
        props.addEditEvent((JSON.parse(JSON.stringify(modify))), props.eventIndex);
        setModal(!modal);
    }
    const updateError = (err) => {
        console.log(err);
        Toastr.error("There was an error saving the record! " + err);
    }
    //SAVE BEGIN


    //cancel the edit modal window
    //
    const cancelEdit = (e) => {
        e.preventDefault()
        setEvent(() => { return (JSON.parse(JSON.stringify(holder))) });
        setModify(() => { return (JSON.parse(JSON.stringify(holder))) });
    }

    //on click of View More, pass the index
    //to the Events page to display the proper
    //events record
    //
    const onViewMore = (e) => {
        e.preventDefault();
        props.changePrimaryView(e.currentTarget.dataset.index);
    }

    //invoked when onChange event fires for
    //select elements
    //
    const localFormFieldChange = (e) => {
        e.preventDefault();

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
        setModify((prevEvent) => {

            // copy the previous state
            //
            let newEvent = { ...prevEvent };

            // change the value of the copied object using the name and using bracket notation
            // some exceptions are that a few fields don't sit at the same level with the other 
            // properties of the JSON
            // if (name === "dateStart") {
            //     newEvent.metaData.dateStart = value;
            // } else if (name === "dateEnd") {
            //     newEvent.metaData.dateEnd = value;
            // } else if (name === "address") {
            //     newEvent.metaData.location.address = value;
            // } else if (name === "zipCode") {
            //     newEvent.metaData.location.zipCode = value;
            // }
            // else {
            newEvent[name] = value;  //  <- bracket notation!!!!
            //}

            return newEvent;
        });

    }

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

    return (

        <React.Fragment>
            <tr><td>
                <div className="card">
                    <div className="card-body">
                        <h5 className="card-title">{event.name}</h5>
                        <p className="card-text">{event.description}</p>
                        <p className="card-text">{event.summary}</p>
                    </div>
                    <div>
                        <button type="button" data-index={props.eventIndex} onClick={toggle} className="btn btn-primary btn-sm m-1 select">Edit</button>
                        <button color="danger" data-index={props.eventIndex} onClick={onViewMore} className="btn btn-info btn-sm m-1 select">View More</button>
                    </div>
                </div >
            </td></tr>
            <Modal isOpen={modal} toggle={toggle} >
                <ModalHeader toggle={toggle}><b><u>{modify.name}</u></b></ModalHeader>
                <ModalBody>
                    <div className="App">
                        <table className="table">
                            <tr><td>
                                <h6>Enter date range</h6>
                                <input id="dateStart" data-index={props.eventIndex} name="dateStart" className="form-control mb-1" value={modify.dateStart} type="datetime-local" onChange={localFormFieldChange} />
                                <input id="dateEnd" data-index={props.eventIndex} name="dateEnd" className="form-control mb-1" value={modify.dateEnd} type="datetime-local" onChange={localFormFieldChange} />

                            </td></tr>
                            <tr><td className="h6">
                                Title

                                <input type="text" id={modify.id + "name"} name="name" data-index={props.eventIndex} value={modify.name} className="form-control" onChange={localFormFieldChange} />
                            </td></tr>
                            <tr><td className="h6">

                                Image
                                <input type="text" id={modify.id + "headline"} name="headline" data-index={props.eventIndex} value={modify.headline} className="form-control" onChange={localFormFieldChange} />
                            </td></tr>

                            <tr><td className="h6">
                                Description

                                <input type="text" id={modify.id + "description"} name="description" data-index={props.eventIndex} value={modify.description} className="form-control" onChange={localFormFieldChange} />
                            </td></tr>
                            <tr><td className="h6">
                                Summary

                                <input type="text" id={modify.id + "summary"} name="summary" data-index={props.eventIndex} value={modify.summary} className="form-control" onChange={localFormFieldChange} />
                            </td></tr>
                            <tr><td className="h6">
                                Slug


                                <input type="text" id={modify.id + "slug"} name="slug" data-index={props.eventIndex} value={modify.slug} className="form-control" onChange={localFormFieldChange} />
                            </td></tr>
                            <tr><td className="h6">
                                Status

                                <select id={modify.id + "statusId"} name="statusId" value={modify.statusId} data-index={props.eventIndex} onChange={localFormFieldChange} className="form-select">
                                    <option value="">Select a status</option>
                                    <option value="Active">Active</option>
                                    <option value="NotSet">No status</option>
                                    <option value="Deleted">Deleted</option>
                                    <option value="Flagged">Flagged</option>
                                </select>
                            </td></tr>


                            <tr><td className="h6">
                                Address

                                {/* <input type="text" id={modify.id + "address"} name="address" data-index={props.eventIndex} value={modify.metaData.location.address} className="form-control" onChange={localFormFieldChange} /> */}
                                <Autocomplete
                                    onLoad={onLoad}
                                    onPlaceChanged={onPlaceChanged}
                                >
                                    <input type="text" id={modify.id + "address"} name="address" data-index={props.eventIndex} value={modify.address} className="form-control" onBlur={localFormFieldChange} onChange={localFormFieldChange} />
                                </Autocomplete>

                            </td></tr>
                            <tr><td className="h6">
                                Zip Code
                                <input type="text" id={modify.id + "zipCode"} name="zipCode" data-index={props.eventIndex} value={modify.zipCode} className="form-control" onChange={localFormFieldChange} />
                            </td></tr>

                        </table>
                    </div>



                </ModalBody>
                <ModalFooter>
                    <Button color="Save" id="modify" name="modify" className="btn-primary" data-index={props.eventIndex} onClick={onLocalEventModify}>
                        Save
                    </Button>{' '}
                    <Button color="secondary" className="btn-info" onClick={toggle}>
                        Cancel
                    </Button>
                </ModalFooter>
            </Modal>


        </React.Fragment >

    );

}

export default Event;
//export default React.memo(Person);  <- memoize to prevent useless re-renderings
//not ideal to use when utilizing callbacks, shich is what this component does