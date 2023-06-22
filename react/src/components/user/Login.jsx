//Stand-alone login page for the Sabio API
//You should be able to insert this with Routes
//into an existing App.jsx component without making
//any changes.
//
import React, { useState } from "react";
import * as usersService from "../../services/usersService";
import Toastr from "toastr";

//formik code added 5/4/2023
import { Formik, Form, Field, ErrorMessage } from "formik";
import * as Yup from "yup";

function Login(props) {

  //formik code added 5/4/2023
  const basicSchema = Yup.object().shape({
    email: Yup.string().email("Invalid Email!").required("Email is required!").max(100, "Hey! Email must have less than 101 characters!"),
    password: Yup.string().required("Please provide a password!").max(64, "Hey! Password must have less than 65 characters!")
  })

  //Init the navigate hook
  //
  //const navigate = useNavigate();

  //Build the framework for the state
  //This JSON outline is exactly how a 
  //Login record is defined by the 
  //Sabio API page. 
  //
  const [user, setUser] = useState({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    //tenantId: "",
    roles: "",
    isLoggedIn: false
  });

  //Form field function to change state with
  //every onChange with the input HTML elements.
  //This was copied and modified from the Sabio
  //Wiki example.
  //Parameters:
  //- e - Event object
  // 
  const onFormFieldChange = (e) => {   //captures this event

    //Assign the target of the event to the target variable
    //
    const target = e.target;

    //This is the value to update the state with
    //
    const value = target.value;

    //This is the name of the target. Your HTML elements
    //MUST have the name property set for this to work.
    //
    const name = target.name;

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setUser(prevUser => {

      // copy the previous state
      //
      const newUserObject = {
        ...prevUser
      };

      //change the value of the copied object using the name and using bracket notation
      //
      newUserObject[name] = value;  //  <- bracket notation!!!!

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newUserObject;
    });
  };

  //Login function
  //Invoked by the submit/login button.
  //Makes API call to log in.
  //Parameters:
  //- e - Event object
  // 
  const onLogin = (e) => {

    //Prevent the page from reloading
    //
    e.preventDefault();

    //Invoke add with the current user state
    //as the payload. They both share the
    //same schema.
    //
    usersService
      .login(getLoginJson(user))
      .then(loginSuccess)
      .catch(loginError);
  }

  const getLoginJson = (aUser) => {

    return (
      {
        email: aUser.email,
        password: aUser.password
      }
    )
  }

  //Successful login
  //Parameters:
  //- response - The returned Sabio API object
  //  via axios
  // 
  const loginSuccess = (response) => {

    //Required to prevent error of non-use
    //
    console.log("loginSuccess:" + response);

    //get current user to build a 
    //new state JSON to pass to
    //the App.jsx component
    //getUserById will be next
    //
    usersService
      .getCurrentUser()
      .then(getSuccess)
      .catch(getFail)
  }

  //Successful get of current user
  //Parameters:
  //- response - The returned Sabio API object
  //  via axios
  // 
  const getSuccess = (response) => {
    console.log("Get Current User Success:" + response);

    //get user by id to build a 
    //new state JSON to pass to
    //the App.jsx component
    //
    usersService
      .getUserById(response.data.item)
      .then(getByIdSuccess)
      .catch(getByIdFail)
  }

  //Successful get of user by id
  //Parameters:
  //- response - The returned Sabio API object
  //  via axios
  // 
  const getByIdSuccess = (response) => {
    console.log("Get Current User Success:" + response);

    //this is a sub-state of the current state of this
    //login page.
    //
    let userState = {
      firstName: response.data.item.firstName,
      lastName: response.data.item.lastName,
      roles: response.data.item.roles,
      isLoggedIn: true,
      type: "USER_LOGGED_IN"
    }

    //Passing a sub-state JSON of the 
    //current login state object to the
    //App.jsx component
    //
    props.sendAppLoginState(userState);
  }

  //Unsuccessful get of current user by id
  //Parameters:
  //- err - The returned Sabio API object
  //  via axios
  // 
  const getByIdFail = (err) => {
    console.log("Get Current User By Id Fail:" + err);
  }

  //Unsuccessful get of current user
  //Parameters:
  //- err - The returned Sabio API object
  //  via axios
  // 
  const getFail = (err) => {
    console.log("Get Current User Fail:" + err);
  }

  //Unsuccessful login
  //Parameters:
  //- err - The returned Sabio API object
  //  via axios
  // 
  const loginError = (err) => {

    //Build error response
    //
    console.log("loginError:" + err);
    Toastr.warning(err);
  }

  return (
    <React.Fragment>
      {/* <div className="container">
        <div className="p-5 mb-4 bg-light rounded-3">
          <div className="container-fluid py-5"> */}


      {/* formik code added 5/4/2023 */}
      <Formik
        enableReinitialize={true}
        initialValues={user}
        // onSubmit={this.handleSubmit}
        validationSchema={basicSchema}

      >
        {(values) => (  //handle the inputs via Formik ... if you wanted to reference state values

          <Form name="loginform" className="text-center mt-3 position-absolute top-5 start-50 translate-middle-x">
            <h1 className="h3 font-weight-normal">Please Log In</h1>

            <Field value={values.email} id="email" type="text" onChange={onFormFieldChange} name="email" className="form-control m-1" placeholder="Email address" style={{ maxwidth: "50px" }} autoFocus></Field>
            <ErrorMessage name="email" component="div" className="has-error"></ErrorMessage>

            <Field value={values.password} id="password" type="password" onChange={onFormFieldChange} name="password" className="form-control m-1" placeholder="password"></Field>
            <ErrorMessage name="password" component="div" className="has-error"></ErrorMessage>

            {/* <p><label><a href="https://sabio.la/privacypolicy">terms and conditions</a></label> </p> */}
            <button onClick={onLogin} className="btn btn-primary m-1" id="login">Complete Login</button>
          </Form>
        )}
      </Formik>
      {/* </div>
        </div>
      </div> */}
      {/* <Navigate></Navigate> */}
    </React.Fragment>
  );
}

export default Login;
