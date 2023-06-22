//This Job functional component displays just
//one card per jobs record. It receives a single
//job object from the array of jobs in the
//state of the parent component.
//                      
//There are also two local click handlers, 
//one for delete and one for edit, which
//call to the parent functions defined in 
//the properties.
//
import React, { useState } from "react";

//for modal
//
import { Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';

function Job(props) {

    //set a local job person record
    const thisJob = props.aJob;

    //state for modal
    //
    const [modal, setModal] = useState(false);

    //toggle function, which sets te state
    //
    const toggle = () => setModal(!modal);

    //delete click handler
    //
    const onLocalJobEdit = (e) => {
        e.preventDefault()
        props.editThisJob(thisJob, e);
    }

    //edit click handler 
    //
    const onLocalJobDelete = (e) => {
        e.preventDefault()
        props.deleteThisJob(e);
        //props.deleteThisJob();
    }

    //split the skills array into a comma-separated
    //list
    //Parameter:
    //- anArray - An array of data
    //-
    const commaSepSkills = (anArray) => {
        let aString = "<ul>";
        for (let index = 0; index < anArray.length; index++) {
            if (index === anArray.length - 1) {
                aString += anArray[index].name + "</ul>";
            } else {
                aString += "<li>" + anArray[index].name + "</li>";
            }
        }
        return aString;
    }

    return (

        <React.Fragment>
            <div className="card" style={{ width: "18rem" }}>
                <img className="card-img-top" src={thisJob.techCompany.images[0].imageUrl} alt={thisJob.techCompany.images[0].imageUrl} />
                <div className="card-body">
                    <h5 className="card-title">{thisJob.title}</h5>
                    <p className="card-text">{thisJob.pay}</p>
                    <p className="card-text">{thisJob.summary}</p>
                </div>
                <div style={{ alignContent: "baseline", padding: "20px" }}>
                    <button type="button" data-page={"/jobs/" + thisJob.id} onClick={onLocalJobEdit} className="btn btn-primary btn-sm m-1 select">Edit</button>
                    <button type="button" onClick={onLocalJobDelete} id={thisJob.id} className="btn btn-danger btn-sm m-1 delete">Delete</button>
                    <button color="danger" className="btn btn-primary btn-sm m-1 select" onClick={toggle}>View More</button>
                </div>
            </div >

            <Modal isOpen={modal} toggle={toggle} >
                <ModalHeader toggle={toggle}>More Information on the <b><u>{thisJob.title}</u></b> position.</ModalHeader>
                <ModalBody>
                    <div className="App">
                        <table className="table">
                            <tr><td>
                                <img src={thisJob.techCompany.images[0].imageUrl} alt="" style={{ width: "150px", height: "150px" }}></img>
                            </td><td>
                                </td></tr>
                            <tr><td className="h5">
                                Title
                            </td><td>
                                    {thisJob.title}
                                </td></tr>
                            <tr><td className="h5">
                                Description
                            </td><td>
                                    {thisJob.description}
                                </td></tr>
                            <tr><td className="h5">
                                Summary
                            </td><td>
                                    {thisJob.summary}
                                </td></tr>
                            <tr><td className="h5">
                                Pay
                            </td><td>
                                    ${thisJob.pay}
                                </td></tr>
                            <tr><td className="h5">
                                Slug
                            </td><td>
                                    {thisJob.slug}
                                </td></tr>
                            <tr><td className="h5">
                                Status
                            </td><td>
                                    {thisJob.statusId}
                                </td></tr>
                            <tr><td className="h5">
                                Skills
                            </td><td dangerouslySetInnerHTML={{ __html: commaSepSkills(thisJob.skills) }} >

                                </td></tr>
                            <tr><td className="h5">
                                Company Name
                            </td><td>
                                    {thisJob.techCompany.name}
                                </td></tr>
                            <tr><td className="h5">
                                Headline
                            </td><td>
                                    {thisJob.techCompany.headline}
                                </td></tr>
                            <tr><td className="h5">
                                Profile
                            </td><td>
                                    {thisJob.techCompany.profile}
                                </td></tr>
                            <tr><td className="h5">
                                Summary
                            </td><td>
                                    {thisJob.techCompany.summary}
                                </td></tr>
                            <tr><td className="h5">
                                Contact
                            </td><td>
                                    {thisJob.techCompany.contactInformation.data}
                                </td></tr>
                        </table>
                    </div>



                </ModalBody>
                <ModalFooter>
                    <Button color="primary" data-page={"/jobs/" + thisJob.id} onClick={onLocalJobEdit}>
                        Edit
                    </Button>{' '}
                    <Button color="secondary" onClick={toggle}>
                        Cancel
                    </Button>
                </ModalFooter>
            </Modal>


        </React.Fragment >

    );

}

export default Job;
//export default React.memo(Person);  <- memoize to prevent useless re-renderings
//not ideal to use when utilizing callbacks, shich is what this component does