import React from "react";

function Movie(props) {




    return (

        <React.Fragment>

            <div className="card" style={{ width: "18rem" }}>
                <div className="card-body">
                    <h5 className="card-title">Name: {props.aMovie.name}</h5>
                    <p className="card-text">Year: {props.aMovie.year}</p>
                    <p className="card-text">Rating: {props.aMovie.rating}</p>
                </div>
                {/* <div style={{ alignContent: "baseline", padding: "20px" }}>
                    <button type="button">Select Me</button>
                </div> */}
            </div >

        </React.Fragment>





    );





}

export default Movie;