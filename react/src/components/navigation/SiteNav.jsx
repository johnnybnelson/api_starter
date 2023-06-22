import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";   //
import * as usersService from "../../services/usersService";
import { useNavigate } from "react-router-dom";

function SiteNav(props) {

    const navigate = useNavigate();

    const [state, setState] = useState(props.user);
    console.log("state", state);
    console.log("props.user", props.user);

    const startLogout = (e) => {
        e.preventDefault();
        usersService
            .logout()
            .then(logoutSuccess)
            .catch(logoutFail);
    }

    const getLoginButton = () => {
        return (<Link to="/login" type="button" className="btn btn-outline-light me-2">Login</Link>);
    }

    const getRegisterButton = () => {
        return (<Link to="/register" type="button" className="btn btn-warning">Register</Link>);
    }

    const getLogoutButton = () => {
        return (<Link to="" type="button" onClick={startLogout} className="btn btn-warning">Logout</Link>);
    }

    const logoutSuccess = (response) => {
        console.log("response", response)

        setState((prevState) => {

            //make a copy of the previous state
            //
            const tempState = { ...prevState };

            //Toggle the showContent boolean
            //
            tempState.isLoggedIn = false;
            tempState.type = "USER_LOGGED_OUT";

            //This returned object becomes the 
            //new state. Re-render to follow.
            //
            return tempState;
        });


        //props.pingUserStatus();
        //navigate("/login");
    }

    const logoutFail = (err) => {
        console.log("Logout error", err);
        navigate("/login");
    }

    // this is invoked following successful mount
    // 
    useEffect(() => {
        console.log("App mounted!");
        if ((!state.isLoggedIn) && (state.type === "USER_LOGGED_OUT")) {
            props.sendAppLogoutState(state);
        }
        if ((state.type === "USER_INITIAL") && (props.user.type === "USER_LOGGED_IN")) {
            setState(() => {

                //This returned object becomes the 
                //new state. Re-render to follow.
                //
                return props.user;
            });
        }
    }, [state.isLoggedIn, state.type]);


    return (
        <React.Fragment>
            <nav
                className="navbar navbar-expand-md navbar-dark bg-dark"
                aria-label="Fourth navbar example"
            >
                <div className="container">
                    <Link to={(props.user.isLoggedIn) ? "/" : "/login"} className="navbar-brand" href="/">
                        <img

                            src="https://pw.sabio.la/images/Sabio.png"
                            width="30"
                            height="30"
                            className="d-inline-block align-top"
                            alt="Sabio"
                        />
                    </Link>
                    <button
                        className="navbar-toggler"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#navbarsExample04"
                        aria-controls="navbarsExample04"
                        aria-expanded="false"
                        aria-label="Toggle navigation"
                    >
                        <span className="navbar-toggler-icon"></span>
                    </button>

                    <div className="collapse navbar-collapse" id="navbarsExample04">
                        <ul className="navbar-nav me-auto mb-2 mb-md-0">
                            <li className="nav-item">
                                <Link to={(props.user.isLoggedIn) ? "/" : "/login"}
                                    className="nav-link px-2 text-white link-button"
                                >
                                    Home
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link to={(props.user.isLoggedIn) ? "/friends" : "/login"}
                                    className={((props.user.roles === "admin") || (props.user.roles === "user")) ? "nav-link px-2 text-white link-button" : "d-none"}
                                >
                                    Friends
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link
                                    to={(props.user.isLoggedIn) ? "/jobs" : "/login"}
                                    // href="#"
                                    className={((props.user.roles === "admin") || (props.user.roles === "user")) ? "nav-link px-2 text-white link-button" : "d-none"}
                                >
                                    Jobs
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link
                                    to={(props.user.isLoggedIn) ? "/companies" : "/login"}
                                    //href="#"
                                    className={(props.user.roles === "admin") ? "nav-link px-2 text-white link-button" : "d-none"}
                                >
                                    Tech Companies
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link
                                    to={(props.user.isLoggedIn) ? "/events" : "/login"}
                                    //href="#"
                                    className={((props.user.roles === "admin")) ? "nav-link px-2 text-white link-button" : "d-none"}
                                >
                                    Events
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link
                                    to={(props.user.isLoggedIn) ? "/files" : "/login"}
                                    //href="#"
                                    className={((props.user.roles === "admin")) ? "nav-link px-2 text-white link-button" : "d-none"}
                                >
                                    File Uploads
                                </Link>
                            </li>
                            <li className="nav-item">
                                <Link
                                    to={(props.user.isLoggedIn) ? "/assessments" : "/login"}
                                    //href="#"
                                    className={((props.user.roles === "admin") || (props.user.roles === "user") || (props.user.roles === "visitor")) ? "nav-link px-2 text-white link-button" : "d-none"}
                                >
                                    Assessments
                                </Link>
                            </li>
                        </ul>
                        <div className="text-end">
                            <div className="align-items-center mb-2 me-2 mb-lg-0 text-white text-decoration-none">
                                <label className="px-2">{(props.user.isLoggedIn) ? `${props.user.firstName} ${props.user.lastName} (${props.user.roles}) ` : "Nobody Logged In  "}</label>
                                {(props.user.isLoggedIn) ? getLogoutButton() : getLoginButton()} {(props.user.isLoggedIn) ? "" : getRegisterButton()}
                            </div>
                        </div>
                    </div>
                </div>
            </nav>


        </React.Fragment >
    );
}

export default SiteNav;