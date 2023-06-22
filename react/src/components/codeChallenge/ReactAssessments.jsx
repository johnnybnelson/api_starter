import React from 'react';
import Loki from 'react-loki';
import PoliticalCandidates from "./PoliticalCandidates";
import MoviesList from "../../components/movieslist/MoviesList";
import Basic from "../formik/Basic";

function ReactAssessments() {

    const mySteps = [
        {
            label: 'Step 1',
            //icon: <PoliticalCandidates />, //optional,
            component: <PoliticalCandidates />
        },
        {
            label: 'Step 2',
            //icon: <MoviesList />, //optional,
            component: <MoviesList />
        },
        {
            label: 'Step 3',
            //icon: <MoviesList />, //optional,
            component: <Basic />
        }
    ];

    const _onFinish = () => {
        console.log('Loki finished!');
    }

    return (

        <div className="col-8">
            <Loki steps={mySteps} backLabel="Previous" nextLabel="Continue" onFinish={_onFinish} />
        </div>
    );

}
export default ReactAssessments;
