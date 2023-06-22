import React, { useState, useEffect } from "react";
import "./App.css";
import SiteNav from "./components/navigation/SiteNav";
import Home from "./Home";
import Login from "./components/user/Login";
import Register from "./components/user/Register";
import Companies from "./components/companies/Companies";
import Jobs from "./components/jobs/Jobs";
import Friends from "./components/friends/Friends";
import Events from "./components/events/Events";
import NewEditFriends from "./components/friends/NewEditFriends";
import NewEditJobs from "./components/jobs/NewEditJobs";
import NewEditCompanies from "./components/companies/NewEditCompanies";
import FileUpload from "./components/files/FileUpload";
import { Routes, Route, useNavigate } from "react-router-dom";
import * as usersService from "./services/usersService";
import ReactAssessments from "./components/codeChallenge/ReactAssessments";

function App() {

  console.log("App Rendering");
  const navigate = useNavigate();

  //set state to initial settings
  //
  const [state, setState] = useState({
    firstName: "temp",
    lastName: "user",
    isLoggedIn: false,
    type: "USER_INITIAL",
    roles: "visitor"
  });

  //Sets the user login  state
  //Parameters:
  //- someState - This is a state object
  //
  const setUserLoginState = (someState) => {

    setState(() => {

      //may or may not be necessary
      //still working this one out
      //
      if (!someState.isLoggedIn) {
        if (someState.isLoggedIn === false) {
          someState.isLoggedIn = null;
        } else {
          someState.isLoggedIn = false;
        }
      }

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return someState;
    });
  }

  //Successfully retrieved the user via API
  //Parameters:
  //- response - API return via axios
  //
  const userSuccess = (response) => {
    console.log("userSuccess", response);

    usersService
      .getUserById(response.data.item)
      .then(userByIdSuccess)
      .catch(userByIdFail);

  }

  //Unsuccessfully retrieved the user via API
  //Parameters:
  //- err - API return via axios
  //
  const userFail = (err) => {
    console.log("userFail", err);

    let userState = {
      firstName: "Nobody",
      lastName: "Logged In",
      roles: "",
      isLoggedIn: false,
      type: "USER_LOGGED_OUT"
    }
    setUserLoginState(userState);
  }


  //Successfully retrieved the user by ID
  //Parameters:
  //- response - API return via axios
  //
  const userByIdSuccess = (response) => {

    let userState = {
      firstName: response.data.item.firstName,
      lastName: response.data.item.lastName,
      roles: response.data.item.roles,
      isLoggedIn: true,
      type: "USER_LOGGED_IN"
    }

    setUserLoginState(userState);
  }

  //Unsuccessfully retrieved the user by ID
  //Parameters:
  //- response - API return via axios
  //
  const userByIdFail = (err) => {
    console.log("userByIdFail", err);

    let userState = {
      firstName: "Nobody",
      lastName: "Logged In",
      roles: "",
      isLoggedIn: false,
      type: "USER_LOGGED_OUT"
    }
    setUserLoginState(userState);
  }

  //Receives a login state from either the
  //Login.jsx or the SiteNav.jsx
  //Parameters:
  //- loginState - this is a state that matches
  //  the user state for this component
  //
  const receiveUserState = (loginState) => {
    console.log("loginState", loginState);
    setUserLoginState(loginState);
  }

  //On startup of the site, or on refresh
  //of the Web app, check to see if the 
  //user is already ogged in
  //
  const checkUserState = () => {

    usersService
      .getCurrentUser()
      .then(userSuccess)
      .catch(userFail);
  }


  // this is invoked following successful mount
  // 
  useEffect(() => {
    console.log("App mounted!");
    if (state.type === "USER_INITIAL") {
      checkUserState();
    } else if (state.type === "USER_LOGGED_OUT") {
      navigate("/login");
    } else if (state.type === "USER_LOGGED_IN") {
      navigate("/");
    }
  }, [state.isLoggedIn, state.type]);

  var copyOfState = { ...state };

  return (

    <React.Fragment>
      <SiteNav user={copyOfState} sendAppLogoutState={receiveUserState}></SiteNav>

      {/* <PracticeAssessment /> */}

      <main className="container" role="main">
        {/* This routes sectin will display the component
            indicated by the element property (example <Home>). 
            The path value must match a Link element's "to" attribute.
            The component must be declared/imported at the top of the page
             */}

        <Routes>

          {/* EVERYONE */}
          <Route path="/" element={<Home></Home>}></Route>
          <Route path="/login" element={<Login sendAppLoginState={receiveUserState}></Login>}></Route>
          <Route path="/register" element={<Register></Register>}></Route>

          {/* ADMIN */}
          {state.roles === "admin" ? <Route path="/companies" element={<Companies></Companies>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/companies/new" element={<NewEditCompanies></NewEditCompanies>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/companies/:companyId" element={<NewEditCompanies></NewEditCompanies>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/jobs" element={<Jobs></Jobs>} ></Route> : ""}
          {state.roles === "admin" ? <Route path="/jobs/new" element={<NewEditJobs></NewEditJobs>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/jobs/:jobId" element={<NewEditJobs></NewEditJobs>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/events" element={<Events></Events>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/files" element={<FileUpload></FileUpload>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/friends" element={<Friends></Friends>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/friends/new" element={<NewEditFriends></NewEditFriends>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/friends/:friendId" element={<NewEditFriends></NewEditFriends>}></Route> : ""}
          {state.roles === "admin" ? <Route path="/assessments" element={<ReactAssessments></ReactAssessments>}></Route> : ""}

          {/* USER */}
          {state.roles === "user" ? <Route path="/jobs" element={<Jobs></Jobs>} ></Route> : ""}
          {state.roles === "user" ? <Route path="/jobs/new" element={<NewEditJobs></NewEditJobs>}></Route> : ""}
          {state.roles === "user" ? <Route path="/jobs/:jobId" element={<NewEditJobs></NewEditJobs>}></Route> : ""}
          {state.roles === "user" ? <Route path="/friends" element={<Friends></Friends>}></Route> : ""}
          {state.roles === "user" ? <Route path="/friends/new" element={<NewEditFriends></NewEditFriends>}></Route> : ""}
          {state.roles === "user" ? <Route path="/friends/:friendId" element={<NewEditFriends></NewEditFriends>}></Route> : ""}
          {state.roles === "user" ? <Route path="/assessments" element={<ReactAssessments></ReactAssessments>}></Route> : ""}

          {/* VISITOR */}
          {state.roles === "visitor" ? <Route path="/assessments" element={<ReactAssessments></ReactAssessments>}></Route> : ""}

        </Routes>


      </main >
      <footer className="container">
        <p>&copy; Sabio 2019-2020</p>
      </footer>
    </React.Fragment >
  );
}

export default App;