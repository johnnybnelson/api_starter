//This Company functional component displays just
//one card per companies record. It receives a single
//Company object from the array of companies in the
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

function Company(props) {

    //set a local Company person record
    const thisCompany = props.aCompany;

    //state for modal
    //
    const [modal, setModal] = useState(false);

    //toggle function, which sets te state
    //
    const toggle = () => setModal(!modal);

    //delete click handler
    //
    const onLocalCompanyEdit = (e) => {
        e.preventDefault()
        props.editThisCompany(thisCompany, e);
    }

    //edit click handler 
    //
    const onLocalCompanyDelete = (e) => {
        e.preventDefault()
        props.deleteThisCompany(e);
    }

    return (

        <React.Fragment>
            <div className="card" style={{ width: "18rem" }}>
                <img className="card-img-top" src={thisCompany.images ? thisCompany.images[0].imageUrl : "/favicon.ico"} alt={thisCompany.images ? thisCompany.images[0].imageUrl : "No Image"} />
                <div className="card-body">
                    <h5 className="card-title">{thisCompany.name}</h5>
                    <p className="card-text">{thisCompany.headline}</p>
                    <p className="card-text">{thisCompany.summary}</p>
                    <p className="card-text">{thisCompany.statusId}</p>
                </div>
                <div style={{ alignContent: "baseline", padding: "20px" }}>
                    {/* <button type="button" data-page={"/companies/" + thisCompany.id} onClick={onLocalCompanyEdit} className={((props.pageType === "COMPANIES_SEARCH_A") || (props.pageType === "COMPANIES_SEARCH_B")) ? "d-none" : "btn btn-primary btn-sm m-1 select"}>Edit</button> */}
                    <button type="button" data-page={"/companies/" + thisCompany.id} onClick={onLocalCompanyEdit} className="btn btn-primary btn-sm m-1 select">Edit</button>
                    <button type="button" onClick={onLocalCompanyDelete} id={thisCompany.id} className="btn btn-danger btn-sm m-1 delete">Delete</button>
                    <button color="danger" className="btn btn-primary btn-sm m-1 select" onClick={toggle}>View More</button>
                </div>
            </div >

            <Modal isOpen={modal} toggle={toggle} >
                <ModalHeader toggle={toggle}>More Information on the <b><u>{thisCompany.title}</u></b> position.</ModalHeader>
                <ModalBody>
                    <div className="App">
                        <table className="table">
                            <tr><td>
                                <img src={thisCompany.images ? thisCompany.images[0].imageUrl : "/favicon.ico"} alt="" style={{ width: "150px", height: "150px" }}></img>
                            </td><td>
                                </td></tr>
                            <tr><td className="h5">
                                Name
                            </td><td>
                                    {thisCompany.name}
                                </td></tr>
                            <tr><td className="h5">
                                headline
                            </td><td>
                                    {thisCompany.headline}
                                </td></tr>
                            <tr><td className="h5">
                                Summary
                            </td><td>
                                    {thisCompany.summary}
                                </td></tr>
                            <tr><td className="h5">
                                Profile
                            </td><td>
                                    {thisCompany.profile}
                                </td></tr>
                            <tr><td className="h5">
                                Slug
                            </td><td>
                                    {thisCompany.slug}
                                </td></tr>
                            <tr><td className="h5">
                                Contact Info
                            </td><td>
                                    {thisCompany.contactInformation ? thisCompany.contactInformation.data : "No Copntact in Search"}
                                </td></tr>
                            <tr><td className="h5">
                                Web Site
                            </td><td>
                                    <a target="_blank" rel="noreferrer" href={thisCompany.urls ? thisCompany.urls[0].url : "No URL in Search"}>{thisCompany.urls ? thisCompany.urls[0].url : "No URL in Search"}</a>
                                </td></tr>
                            <tr><td className="h5">
                                Status
                            </td><td>
                                    {thisCompany.statusId}
                                </td></tr>
                        </table>
                    </div>



                </ModalBody>
                <ModalFooter>
                    {/* className={((props.pageType === "COMPANIES_SEARCH_A") || (props.pageType === "COMPANIES_SEARCH_B")) ? "d-none" : ""} */}
                    <Button color="primary" data-page={"/companies/" + thisCompany.id} onClick={onLocalCompanyEdit}>
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

export default Company;
//export default React.memo(Person);  <- memoize to prevent useless re-renderings
//not ideal to use when utilizing callbacks, shich is what this component does