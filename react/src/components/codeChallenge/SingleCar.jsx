import React from "react";

function SingleCar(props) {

    //clicking the filter button
    const onCarClicked = (e) => {
        e.preventDefault();
        props.onCarClicked({
            make: props.car.make,
            model: props.car.model,
            year: props.car.year
        });
    }

    return (
        <React.Fragment>
            <div className="card" style={{ width: "18rem" }}>
                <div className="card-body">
                    <h5 className="card-title">{props.car.make}</h5>
                    <p className="card-text">{props.car.year}</p>
                    <p className="card-text">{props.car.model}</p>
                </div>
                <div style={{ alignContent: "baseline", padding: "20px" }}>
                    <button type="button" onClick={onCarClicked} className={props.showButton ? "select-me btn-primary" : "d-none"}>Select Me</button>
                    {/* {props.showButton ? <button type="button" onClick={onCarClicked} >Select Me</button> : ""} */}
                </div>
            </div >

        </React.Fragment>
    )



}

export default SingleCar;