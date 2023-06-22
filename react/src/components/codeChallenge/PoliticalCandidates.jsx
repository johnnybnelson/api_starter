import React, { useState } from "react";
import PoliticalCandidateCard from "./PoliticalCandidateCard";
import politicalCandidateService from "./services/politicalCandidateService";

function PoliticalCandidates() {

    const [form1, setForm1] = useState({
        "id": 0,
        "firstName": "",
        "lastName": "",
        "currentVotes": 0,
        "party": "",
        "imageUrl": "",
        "form": 1
    });

    const [form2, setForm2] = useState({
        "id": 0,
        "firstName": "",
        "lastName": "",
        "currentVotes": 0,
        "party": "",
        "imageUrl": "",
        "form": 2
    });

    const buildSubmitPayload = (candidate) => {

        return {
            "firstName": candidate.firstName,
            "lastName": candidate.lastName,
            "currentVotes": candidate.currentVotes,
            "party": candidate.Party,
            "imageUrl": candidate.imageUrl,
            "form": candidate.form,
        }
    }

    const getCardForCandidate = (candidate) => {
        return <PoliticalCandidateCard politicalCandidate={candidate} />
    }

    if (!true) console.log(form1, form2);

    const onForm1FieldChange = (e) => {

        e.preventDefault();

        const target = e.target;

        const value = target.value;
        console.log(value);

        const name = target.name;

        setForm1(prevForm1 => {

            const newObject = {
                ...prevForm1
            };

            newObject[name] = value;


            return newObject;
        });
    };

    const onForm2FieldChange = (e) => {

        e.preventDefault();

        const target = e.target;

        const value = target.value;
        console.log(value)

        const name = target.name.substring(0, target.name.length - 1);

        setForm2(prevForm2 => {

            const newObject = {
                ...prevForm2
            };

            newObject[name] = value;

            return newObject;
        });
    };

    const onReset = (e) => {
        e.preventDefault();

        let buttonId = e.target.id;

        if (buttonId === "reset") {
            resetForm1(form1);
        } else {
            resetForm2(form2);
        }
    }

    const resetForm1 = () => {

        setForm1((prevForm1) => {
            let newObj = { ...prevForm1 };

            newObj.id = 0;
            newObj.firstName = "";
            newObj.lastName = "";
            newObj.party = "";
            newObj.currentVotes = 0;
            newObj.imageUrl = "";

            return newObj;
        })
    }


    const resetForm2 = () => {

        setForm2((prevForm2) => {
            let newObj = { ...prevForm2 };

            newObj.id = 0;
            newObj.firstName = "";
            newObj.lastName = "";
            newObj.party = "";
            newObj.currentVotes = 0;
            newObj.imageUrl = "";

            return newObj;
        })
    }
    const onSubmit = (e) => {
        e.preventDefault();

        let buttonId = e.target.id

        if (buttonId === "submit") {
            console.log("clicked 1");

            if (!form1.firstName) return;
            if (!form1.lastName) return;
            if (!form1.currentVotes) return;
            if (Number(form1.currentVotes) === 0) return;
            if (!form1.party) return;
            if (!form1.imageUrl) return;

            politicalCandidateService
                .add(buildSubmitPayload(form1))
                .then(submit1Success)
                .catch(submit1Error)
        } else {
            console.log("clicked 2")

            if (!form2.firstName) return;
            if (!form2.lastName) return;
            if (!form2.currentVotes) return;
            if (Number(form2.currentVotes) === 0) return;
            if (!form2.party) return;
            if (!form2.imageUrl) return;

            politicalCandidateService
                .add(buildSubmitPayload(form2))
                .then(submit2Success)
                .catch(submit2Error)
        }
    }

    const submit1Success = (response) => {
        console.log(response);

        setForm1((prevForm1) => {
            let newObj = { ...prevForm1 };
            newObj.id = response.data.item;
            return newObj;
        })
    }

    const submit1Error = (err) => {
        console.log(err);
    }

    const submit2Success = (response) => {
        console.log(response);

        setForm2((prevForm2) => {
            let newObj = { ...prevForm2 };
            newObj.id = response.data.item;
            return newObj;
        })

    }

    const submit2Error = (err) => {
        console.log(err);

    }

    const clickShowWinner = (e) => {
        e.preventDefault();
        let candidate1Totals = Number(form1.currentVotes);
        let candidate2Totals = Number(form2.currentVotes);

        if (candidate1Totals > candidate2Totals) {
            setForm1((prevForm1) => {
                let newObj = { ...prevForm1 };
                newObj.winner = true;
                return newObj;
            })
            resetForm2();
        } else if (candidate2Totals > candidate1Totals) {
            setForm2((prevForm2) => {
                let newObj = { ...prevForm2 };
                newObj.winner = true;
                return newObj;
            })
            resetForm1();
        } else {
            //no winner
            console.log("No winner");
        }



    }

    return (

        <div className="container">
            <button id="showWinner" onClick={clickShowWinner}>Show Winner</button>
            <div className="form-left">
                <form id="form1" name="form1">
                    <div className="form-group"><p>First Name</p> <input value={form1.firstName} onChange={onForm1FieldChange} type="text" id="firstName" name="firstName"></input></div>
                    <div className="form-group"><p>Last Name</p> <input type="text" value={form1.lastName} onChange={onForm1FieldChange} id="lastName" name="lastName"></input></div>
                    <div className="form-group"><p>Current Votes</p> <input type="text" value={form1.currentVotes} onChange={onForm1FieldChange} id="currentVotes" name="currentVotes"></input></div>
                    <div className="form-group"><p>Party</p> <select value={form1.party} onChange={onForm1FieldChange} id="party" name="party">
                        <option value=""></option>
                        <option value="democrat">Democrat</option>
                        <option value="republican">Republican</option>
                        <option value="independent">Independent</option>
                    </select></div>
                    <div className="form-group"><p>Avatar</p> <input type="text" value={form1.imageUrl} onChange={onForm1FieldChange} id="imageUrl" name="imageUrl"></input></div>
                    <button id="submit" type="submit" onClick={onSubmit}>Submit</button>
                    <button id="reset" onClick={onReset}>Reset</button>
                    {(form1.id > 0) ? getCardForCandidate(form1) : ""}
                </form>
            </div>
            <div className="form-right">
                <form id="form2" name="form2">
                    <div className="form-group"><p>First Name</p> <input type="text" value={form2.firstName} onChange={onForm2FieldChange} id="firstName2" name="firstName2"></input></div>
                    <div className="form-group"><p>Last Name</p> <input type="text" value={form2.lastName} onChange={onForm2FieldChange} id="lastName2" name="lastName2"></input></div>
                    <div className="form-group"><p>Current Votes</p> <input type="text" value={form2.currentVotes} onChange={onForm2FieldChange} id="currentVotes2" name="currentVotes2"></input></div>
                    <div className="form-group"><p>Party</p> <select value={form2.party} onChange={onForm2FieldChange} id="party2" name="party2">
                        <option value=""></option>
                        <option value="democrat">Democrat</option>
                        <option value="republican">Republican</option>
                        <option value="independent">Independent</option>
                    </select></div>
                    <div className="form-group"><p>Avatar</p> <input type="text" value={form2.imageUrl} onChange={onForm2FieldChange} id="imageUrl2" name="imageUrl2"></input></div>
                    <button id="submit2" type="submit" onClick={onSubmit}>Submit</button>
                    <button id="reset2" onClick={onReset}>Reset</button>
                    {(form2.id > 0) ? getCardForCandidate(form2) : ""}
                </form>
            </div>
        </div>



    );
}
export default PoliticalCandidates;