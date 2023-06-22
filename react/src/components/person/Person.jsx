//This Person functional component displays just
//one card per friend record. It receives a single
//friend object from the array of friends in the
//state of the parent component.
//                      
//There are also two local click handlers, 
//one for delete and one for edit, which
//call to the parent functions defined in 
//the properties.
//
import React from "react";

//prop types added 5/3/2023
import { PropTypes } from "prop-types";


function Person(props) {

    //prop types for the friend/person
    //prop types added 5/3/2023
    Person.propTypes = {
        aPerson: PropTypes.shape({
            id: PropTypes.number.isRequired,
            title: PropTypes.string.isRequired
        }),
        editThisFriend: PropTypes.func,
        deleteThisFriend: PropTypes.func
    }

    //set a local friend person record
    const thisPerson = props.aPerson;

    //delete click handler
    //
    const onLocalPersonDelete = (e) => {
        props.deleteThisFriend(thisPerson, e);
    }

    //edit click handler
    //
    const onLocalPersonEdit = (e) => {
        props.editThisFriend(thisPerson, e);
    }


    return (
        <div className="card" style={{ width: "18rem" }}>
            <img className="card-img-top" src={thisPerson.primaryImage.imageUrl} alt={thisPerson.primaryImage.imageUrl} />
            <div className="card-body">
                <h5 className="card-title">{thisPerson.title}</h5>
                <p className="card-text">{thisPerson.headline}</p>
                <p className="card-text">{thisPerson.summary}</p>
            </div>
            <div style={{ alignContent: "baseline", padding: "40px" }}>
                <button type="button" data-page={"/friends/" + thisPerson.id} onClick={onLocalPersonEdit} className="btn btn-primary btn-sm m-1 select">Edit</button>
                <button type="button" onClick={onLocalPersonDelete} id={thisPerson.id} className="btn btn-danger btn-sm m-1 delete">Delete</button>
            </div>
        </div >
    );
}

export default Person;
//export default React.memo(Person);  <- memoize to prevent useless re-renderings
//not ideal to use when utilizing callbacks, shich is what this component does