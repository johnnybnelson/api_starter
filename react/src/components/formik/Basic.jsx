import React from "react";
import { Formik, Form, Field, ErrorMessage, FieldArray } from "formik";
import * as Yup from "yup";
import "../../App.css";

const basicSchema = Yup.object().shape({
    fullName: Yup.string().min(2, "Hey! Must have two or more characters!").max(50, "Hey! Must have less than 50 characters!").required("Name field is required"),
    email: Yup.string().email("Invalid Email!").required("Email is required!"),
    content: Yup.string().min(10, "Need at least 10 chars!").max(200, "200 chars max!").required(),
    friends: Yup.array().of(
        Yup.object().shape({
            name: Yup.string().min(2, "2 chars required for friend").max(50).required()
        })
    ).required("Required to add friends").min(2)
})


class Basic extends React.Component {


    state = {

        sports: [
            { id: 1, name: "Soccer" },
            { id: 2, name: "Basketball" },
            { id: 3, name: "Football" },
            { id: 4, name: "Cricket" },
            { id: 5, name: "Hockey" }
        ],




        formData: {
            fullName: "",
            email: "",
            isAwesome: false,
            color: "",
            content: "",
            sportId: 0,
            friends: [{ name: "" }]
        }
    };

    handleSubmit = (value) => {
        console.log("value", value);
    }

    mapSport = (sport) => (
        <option value={sport.id} key={`sport_${sport.id}`}>{sport.name}</option>
    )

    render() {

        return (

            <div className="container">
                <div className="row">
                    <div className="col-3">
                        <Formik
                            enableReinitialize={true}
                            initialValues={this.state.formData}
                            onSubmit={this.handleSubmit}
                            validationSchema={basicSchema}

                        >
                            {({ values }) => (
                                <Form>
                                    <div className="form-group">
                                        <label htmlFor="fullName">Full Name: {values.fullName}</label>
                                        <Field type="text" name="fullName" className="form-control"></Field>
                                        <ErrorMessage name="fullName" component="div" className="has-error"></ErrorMessage>
                                    </div>
                                    <hr />
                                    <div className="form-group">
                                        <label htmlFor="email">Email: {values.email}</label>
                                        <Field type="email" name="email" className="form-control"></Field>
                                        <ErrorMessage name="email" component="div" className="has-error"></ErrorMessage>
                                    </div>

                                    <hr />

                                    <h4>Checkbox </h4>
                                    <div className="form-check">
                                        <label className="form-check-label" htmlFor="isAwesome">
                                            Is Awesome? {`${values.isAwesome}`}
                                        </label>
                                        <Field type="checkbox" name="isAwesome" className="form-check-input"></Field>
                                    </div>

                                    <hr />

                                    <h4>Text Area </h4>
                                    <div className="form-group">
                                        <label htmlFor="content">Content</label>
                                        <Field component="textarea" name="content" className="form-control" />
                                        <ErrorMessage name="content" component="div" className="has-error"></ErrorMessage>
                                    </div>

                                    <hr />

                                    <h4>Radios </h4>
                                    <div className="form-check">
                                        <label htmlFor="color" className="form-check-label">Red</label>
                                        <Field key="red" type="radio" name="color" value="red" className="form-check-input" />
                                        <ErrorMessage name="color" component="div" className="has-error"></ErrorMessage>
                                    </div>
                                    <div className="form-check">
                                        <label htmlFor="color" className="form-check-label">Blue</label>
                                        <Field key="blue" type="radio" name="color" value="blue" className="form-check-input" />
                                        <ErrorMessage name="color" component="div" className="has-error"></ErrorMessage>
                                    </div>
                                    <div className="form-check">
                                        <label htmlFor="color" className="form-check-label">Green</label>
                                        <Field key="green" type="radio" name="color" value="green" className="form-check-input" />
                                        <ErrorMessage name="color" component="div" className="has-error"></ErrorMessage>
                                    </div>

                                    <hr />

                                    <h4>Select </h4>
                                    <div className="form-group">
                                        <label htmlFor="sportId">Select a Sport</label>
                                        <Field component="select" name="sportId" className="form-select">
                                            <option value="" key="ABC123">Please select a sport</option>
                                            {this.state.sports.map(this.mapSport)}
                                        </Field>
                                        <ErrorMessage name="sportId" component="div" className="has-error"></ErrorMessage>
                                    </div>

                                    <hr />

                                    <h4>Array List </h4>
                                    <div className="form-group">
                                        <label htmlFor="friends">Friends</label>
                                        <FieldArray name="friends">
                                            {({ push, remove }) => (

                                                <div>
                                                    <button className="btn btn-info"
                                                        onClick={() => push({ name: "" })}
                                                    >
                                                        Add
                                                    </button>


                                                    {
                                                        values.friends &&
                                                        values.friends.map((friend, index) => (

                                                            <div className="row" key={`row_${index}`}>
                                                                <div className="col-10" key={`col_${index}`}>

                                                                    <Field
                                                                        type="text"
                                                                        name={`friends.${index}.name`}
                                                                        className="form-control"
                                                                        placeholder="Add a Friend Name"
                                                                        key={`friend_${index}`}
                                                                    />

                                                                </div>

                                                                <div className="col-2" key={`col2_${index}`}>
                                                                    <button className="btn-danger"
                                                                        onClick={() => remove(index)}
                                                                        key={`delete_${index}`}
                                                                    >
                                                                        Remove
                                                                    </button>
                                                                </div>
                                                                <ErrorMessage name={`friends.${index}.name`} component="div" className="has-error"></ErrorMessage>
                                                            </div>
                                                        ))}

                                                </div>
                                            )}
                                        </FieldArray>
                                        <ErrorMessage name="sportId" component="div" className="has-error"></ErrorMessage>
                                    </div>

                                    <button type="submit" className="btn btn-primary">Submit</button>
                                </Form>
                            )}
                        </Formik>
                    </div>
                </div>
            </div>
        )

    }
}

export default Basic