import React, { useEffect, useState } from "react";
import Movie from "./Movie";

function MoviesList() {

    const [movies, setMovies] = useState({
        movieList: [
            {
                name: "Titanic",
                year: 1997,
                rating: 3
            },
            {
                name: "Casablanca",
                year: 1942,
                rating: 1
            },
            {
                name: "Star Wars",
                year: 1977,
                rating: 5
            },
        ],
        filteredMovies: [],
        filterString: "",
        mappedMovies: []

    }
    );

    const mapMovies = (movie) => {
        return <Movie aMovie={movie}></Movie>
    }


    useEffect(() => {
        setMovies((prevState) => {
            let newObj = { ...prevState };
            newObj.mappedMovies = newObj.movieList.map(mapMovies);
            return newObj;
        });
    }, []);

    const filterMovies = (movie) => {
        if ((movie.rating >= Number(movies.filterString)) || (movies.filterString === "")) {
            return true;
        } else {
            return false;
        }
    }

    useEffect(() => {
        setMovies((prevState) => {
            let newObj = { ...prevState };
            newObj.filteredMovies = newObj.movieList.filter(filterMovies);
            newObj.mappedMovies = newObj.filteredMovies.map(mapMovies);
            return newObj;
        });
    }, [movies.filterString]);

    const filterByRatings = (e) => {

        e.preventDefault();

        setMovies((prevState) => {
            let newObj = { ...prevState };
            newObj.filterString = "3";
            return newObj;
        })

    }



    return (

        <React.Fragment>

            <div>
                <button data-page="3" onClick={filterByRatings}>Greater Than Three!</button>
                {movies.mappedMovies}

            </div>


        </React.Fragment>

    );





}

export default MoviesList;