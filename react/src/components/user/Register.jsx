//Stand-alone register page for the Sabio API
//You should be able to insert this with Routes
//into an existing App.jsx component without making
//any changes.
//
import React, { useState } from "react";
import * as usersService from "../../services/usersService";
import { useNavigate } from "react-router-dom";
import Toastr from "toastr";
import debug from "sabio-debug"; //Added for prod dev class

function Register() {


  const _logger = debug.extend("Register");   //Added for prod dev class

  //Init the navigate hook
  //
  const navigate = useNavigate();  //comes with the useNavigate hook

  //Build the framework for the state
  //This JSON outline is exactly how a 
  //register record is defined by the 
  //Sabio API page. 
  //
  const [user, setUser] = useState({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    passwordConfirm: "",
    avatarUrl: "",
    tenantId: ""
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


  //Register function
  //Invoked by the submit/register button.
  //Makes API call to log in.
  //Parameters:
  //- e - Event object
  // 
  const onSubmitNewRegistrant = (e) => {

    //Prevent the page from reloading
    //
    e.preventDefault();

    //Invoke add with the current user state
    //as the payload. They both share the
    //same schema.
    //
    usersService
      .add(user)
      .then(addSuccess)
      .catch(addError);
  }


  //Successful login
  //Parameters:
  //- response - The returned Sabio API object
  //  via axios
  // 
  const addSuccess = (response) => {

    //Required to prevent error of non-use
    //
    //console.log("addSuccess:" + response);
    _logger("addSuccess:" + response);  //added during prod dev class

    //Let the user know the register was successful
    //
    Toastr.success("Congratulations! Your ID is: " + response.data.item);
    navigate("/login"); //save this for later

  }


  //Unsuccessful register
  //Parameters:
  //- err - The returned Sabio API object
  //  via axios
  // 
  const addError = (err) => {
    console.log("addError:" + err);
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";
    Toastr.warning(errorString);
  }


  return (
    <React.Fragment>

      <form name="registrationForm" className="text-center mt-3 position-absolute top-5 start-50 translate-middle-x">
        <h1 className="h3 mb-3 font-weight-normal">Please Register</h1>
        <label>First Name {user.firstName}</label>
        <input type="text" className="form-control validation" value={user.firstName} name="firstName" id="firstName" onChange={onFormFieldChange} placeholder="Enter first name" />
        <label>Last Name</label>
        <input type="text" className="form-control validation" name="lastName" id="lastName" onChange={onFormFieldChange} placeholder="Enter last name" />
        <label>Email address</label>
        <input type="email" className="form-control validation" name="email" id="email" onChange={onFormFieldChange} placeholder="name@example.com" />
        <label>Password</label>
        <input type="password" className="form-control validation" name="password" id="password" onChange={onFormFieldChange} placeholder="Password" />
        <label>Confirl Password</label>
        <input type="password" className="form-control validation" name="passwordConfirm" id="passwordConfirm" onChange={onFormFieldChange} placeholder="Password confirmation" />
        <label>Avatar URL</label>
        <input type="text" className="form-control validation" name="avatarUrl" id="avatarUrl" onChange={onFormFieldChange} placeholder="Enter the URL of your avatar image file" />
        <label>Tenant ID</label>
        <input type="text" className="form-control validation" name="tenantId" id="tenantId" onChange={onFormFieldChange} placeholder="Enter the unique tenant ID" />
        <label>I agree to the <a href="https://sabio.la/privacypolicy">terms and conditions</a></label>
        <input type="checkbox" value="true" name="agreement" id="agreement" className="form-check-input validation" />
        <p><button type="submit" onClick={onSubmitNewRegistrant} className="btn btn-primary m-1" id="submit">Complete Registration</button>
          {/* <a href="login.html" className="btn btn-primary m-1" role="button">Login</a> */}
        </p>
      </form>

    </React.Fragment>
  );
}

export default Register;
