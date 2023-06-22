import React, { useState, useEffect } from "react";
import carService from "./services/carService";
import SingleCar from "./SingleCar";


function Cars() {

    //This is my cars state
    const [cars, setCars] = useState({
        items: [],                      //these is the array as it comes back from the ajax call
        mappedCars: [],           //this array will hold the mapped components
        filteredCars: [],         //this array will hold the filtered cars
        filterString: "",                //this is the filter string
        showCars: false,
        selectedCar: ""
    });

    //toggle show
    const toggleShowCars = (e) => {
        e.preventDefault();

        setCars((prevState) => {
            let newObj = { ...prevState };
            newObj.filterString = newObj.showCars ? newObj.showCars : "";
            newObj.showCars = !(newObj.showCars);
            newObj.selectedCar = "";
            return newObj;
        })
    }

    //initial loading of cars
    const loadCars = () => {

        //make the ajax call
        carService
            .getAll()
            .then(getSuccess)
            .catch(getError);
    }

    //successfully got all car records
    const getSuccess = (response) => {
        //console.log("getSuccess", response);

        setCars((prevState) => {

            let newObj = { ...prevState };
            newObj.items = response.data;
            newObj.filteredCars = newObj.items;
            newObj.mappedCars = newObj.filteredCars.map(mapCars);
            return newObj
        })
    };

    const getError = (err) => {
        console.log("getError", err);
    };


    //set filter based on passed string
    const setFilter = (e) => {
        e.preventDefault();
        let filterYear = e.currentTarget.dataset.page;

        setCars((prevState) => {
            let newObj = { ...prevState };
            newObj.filterString = filterYear;
            newObj.selectedCar = "";
            return newObj;  //when this is updated, the useEffect is invoked on render
        })
    }

    //called from the SingleCar, then in turn generates one more single car
    const setSelectedCar = (car) => {
        //console.log(setSelectedCar, car);

        setCars((prevState) => {
            let newObj = { ...prevState };
            newObj.selectedCar = <SingleCar id="side-card" showButton={false} car={car}></SingleCar>;
            return newObj;
        })
    }



    //mapping function for cars
    const mapCars = (item) => {
        return <SingleCar key={item.make + "_" + item.model + "_" + item.year} showButton={true} car={{ ...item }} onCarClicked={setSelectedCar}></SingleCar>
        //                 state^^^^     pass the filter string ^^^^^^   function to initiate filter ^^^
    }

    //filtering function for cars
    const filterCars = (car) => {
        if ((cars.filterString === "") || (Number(car.year) === Number(cars.filterString))) {
            return true;  //adds to the filter array
        } else {
            return false; //does not add to the filter array
        }
    }

    //initial load -> runs only once
    useEffect(() => {
        loadCars();
    }, []);


    //runs following initial render and also when the filter string gets changed
    useEffect(() => {

        //if there are cars loaded
        if (cars.items.length > 0) {
            //filter and re-map cars
            setCars((prevState) => {
                let newObj = { ...prevState };
                newObj.filteredCars = newObj.items.filter(filterCars); //newObj.items;
                newObj.mappedCars = newObj.filteredCars.map(mapCars);
                newObj.selectedCar = [];
                return newObj;
            })
        }
    }, [cars.filterString]);

    return (
        <React.Fragment>
            <button onClick={toggleShowCars} data-page="" id="show-all" name="show-all">{cars.showCars ? "Hide Cars" : "Show Cars"}</button>
            <button onClick={setFilter} data-page="2018" id="show-2018-cars" name="2018" disabled={cars.showCars ? false : true} >2018 Cars</button>
            <button onClick={setFilter} data-page="2019" id="show-2019-cars" name="2019" disabled={cars.showCars ? false : true} >2019 Cars</button>
            <button onClick={setFilter} data-page="2020" id="show-2020-cars" name="2020" disabled={cars.showCars ? false : true} >2020 Cars</button>
            <button onClick={setFilter} data-page="2021" id="show-2021-cars" name="2021" disabled={cars.showCars ? false : true} >2021 Cars</button>
            <div className="row">
                <div className="col">
                    {cars.showCars ? cars.mappedCars : ""}
                </div>
                <div className="col">
                    {!((cars.selectedCar) === "") ? cars.selectedCar : ""}
                </div>
            </div>
        </React.Fragment>
    )
}

export default Cars;