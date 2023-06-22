import React, { useState } from "react";
import { Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';

function ListingExercise(props) {

  const [modal, setModal] = useState(false);

  //clicking the filter button
  const onFilterClick = (e) => {
    e.preventDefault();
    props.sendFilter(e.currentTarget.dataset.page);  //<--sends party name to parent for filtering
  }

  const toggleModal = (e) => {
    e.preventDefault();
    setModal(!modal);
  }

  return (
    <React.Fragment>
      <div className="card" style={{ width: "18rem" }}>
        <div className="card-body">
          <h5 className="card-title">{props.president.nm}</h5>
          <p className="card-text">{props.president.pp}</p>
        </div>
        <div style={{ alignContent: "baseline", padding: "20px" }}>
          <button type="button" data-page={props.president.pp} onClick={onFilterClick} className={!(props.filterString === "") ? "d-none" : ""}>Filter By Party</button>
          <Button color="primary" onClick={toggleModal} className="m-3">More...</Button>
        </div>
      </div >

      <Modal isOpen={modal} toggle={toggleModal} >
        <ModalHeader toggle={toggleModal}><b><u>President Information Page</u></b></ModalHeader>
        <ModalBody>
          <div className="App">
            <table className="table">

              <tr>
                <td className="h5">Name</td>
                <td className="h6">{props.president.nm}</td>
              </tr>
              <tr>
                <td className="h5">Party</td>
                <td className="h6">{props.president.pp}</td>
              </tr>
              <tr>
                <td className="h5">Term</td>
                <td className="h6">{props.president.tm}</td>
              </tr>
              <tr>
                <td className="h5"></td>
                <td className="h6">This president was the number {props.president.president}.</td>
              </tr>
            </table>
          </div>
        </ModalBody>
        <ModalFooter>
          <Button color="secondary" className="btn-info" onClick={toggleModal}>
            Cancel
          </Button>
        </ModalFooter>
      </Modal>



    </React.Fragment>
  )



}

export default ListingExercise;