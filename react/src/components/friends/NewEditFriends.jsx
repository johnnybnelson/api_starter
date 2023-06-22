//NewEditFriends functional component called from the 
//Friends component. This component is either activated
//by the link /friends/new or /friends/:friendId. When
//passed with a friendId, it will also include a friend
//record from the state. This friend record does not get 
//passed back to Friends.jsx component. This component 
//will let the user edit/save an existing friend record
//using API calls, but also create a new record.
//
import React, { useState, useEffect } from "react";
import { useParams, useNavigate, useLocation } from "react-router-dom";
import * as friendsService from "../../services/friendsService";
import Toastr from "toastr";

function NewEditFriends() {

  //receives a comma-separated list and places
  //the skills into an array
  //Parameters:
  //- skillsString - A comma-separated list
  //
  const getSkillsArray = (skillsString) => {
    //replace comma-spaces then split into an array
    return skillsString.replace(/, /g, ",").split(",");
  }

  //split the skills array into a comma-separated
  //list
  //Parameter:
  //- anArray - An array of data
  //-
  const commaSepSkills = (anArray) => {
    let aString = "";
    for (let index = 0; index < anArray.length; index++) {
      if (index === anArray.length - 1) {
        aString += anArray[index].name;
      } else {
        aString += anArray[index].name + ", ";
      }
    }
    return aString;
  }

  //Init the useNavigate hook
  //
  const navigate = useNavigate();

  //Init the useLocation hook
  //only grab the state hook 
  //from the location object
  //
  const { state } = useLocation();

  //Init the useParams hook and 
  //only grab the friendId
  //
  const { friendId } = useParams();


  const [skills, setSkills] = useState({
    skillList: commaSepSkills((state) ? state.skills : "")
  });

  if (!true) console.log(skills);

  const onSkillChange = (e) => {
    e.preventDefault();
    setSkills((prevState) => {
      let newObj = { ...prevState };
      newObj.skillList = e.target.value;
      return newObj;
    })
  }

  //Build the framework for the state
  //This JSON outline is exactly how a 
  //friend record is defined by the 
  //API return. An render with a full
  //payload will overwrite this base
  //outline.
  //
  const [friend, setFriend] = useState({
    "bio": "",
    "summary": "",
    "headline": "",
    "skills": [
      {
        "id": 0,
        "name": ""
      }
    ],
    "primaryImage": {
      "id": 0,
      "entityId": 0,
      "imageTypeId": 1,
      "imageUrl": ""
    },
    "id": Number((friendId) ? friendId : 0),
    "shortTitle": "",
    "title": "",
    "shortDescription": "",
    "content": "",
    "createdBy": 0,
    "modifiedBy": 0,
    "slug": "",
    "entityTypeId": 0,
    "statusId": "",
    "dateCreated": "",
    "dateModified": "",
    "baseMetaData": {},
    "site": 0,
    "type": "",
    "friendUrl": ""
  });


  //populate the state with the friends object
  //provided by either the API call or the state
  //object passed from the Friends.jsx component
  //Parameters:
  //- friendObject - A friend object
  //
  const populateFriendState = (friendObject) => {

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setFriend((prevFriend) => {

      //Get a copy of the previous state
      //
      let pageDataComp = { ...prevFriend };

      //Overwrite that with the friend object
      //this step really isn't necessary
      //
      pageDataComp = friendObject;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  }


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
    console.log(name, value)
    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setFriend(prevFriend => {

      // copy the previous state
      //
      const newUserObject = {
        ...prevFriend
      };

      //change the value of the copied object using the name and using bracket notation
      //ONE conditional is the image, which doesn't sit at the same level with the other 
      //properties of the JSON
      //
      if (name === "imageUrl") {
        newUserObject.primaryImage.imageUrl = value;  //  <- bracket notation!!!!
      } else {
        newUserObject[name] = value;  //  <- bracket notation!!!!
      }

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newUserObject;
    });
  };

  //Invoked following mount
  //This function either grabs the friend object
  //from the passed state or using an API call
  //Parameters:
  //- thisFriend - This is the existing state
  //  object with the friendId at a minimum
  //- passedState = This is the state object
  //  (or not). It is either populated or null.
  //
  const getFriend = (thisFriend, passedState) => {

    //if a state was actually passed
    //use it to populate the form.
    //
    if (passedState) {
      populateFriendState(passedState);
    }
    //If a state object is not provided, 
    //perform the API call using the ID
    //
    else {
      friendsService
        .getById(thisFriend.id)
        .then(getSuccess)
        .catch(getError);
    }
  }


  //Successful get of friend record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const getSuccess = (response) => {

    //Since this object was retrieved from the Sabio API, it will
    //not contain the type and friendUrl properties. They are 
    //added here
    //
    let friendObject = { ...response.item, type: "FRIEND_EDIT", friendUrl: "" }

    //Call to populate the input elements
    //
    populateFriendState(friendObject);    //update the state...this re-renders and reflects on the page

    //Let the user know the records were retrieved 
    //successfully
    //
    Toastr.success("Your friend is loaded!");
  }


  //Unsuccessful get of friend record
  //Parmeters:
  //- err - The returned Sabio API object
  //  via axios
  //
  const getError = (err) => {

    //Build the error string
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know the record 
    //retrieval failed
    //
    Toastr.warning(errorString);
  }


  //Build the save API payload
  //This builds the JSON for the 
  //update call to the API
  //
  const getSavePayload = () => {
    return {
      "id": friend.id,
      "title": friend.title,
      "bio": friend.bio,
      "summary": friend.summary,
      "headline": friend.headline,
      "slug": friend.slug,
      "statusId": friend.statusId,
      "imageUrl": friend.primaryImage.imageUrl,
      "imageTypeId": friend.primaryImage.imageTypeId,
      "skills": getSkillsArray(skills.skillList)
    }
  }


  //Build the save API payload
  //This builds the JSON for the 
  //add call to the API
  //
  const getSubmitPayload = () => {
    return {
      "title": friend.title,
      "bio": friend.bio,
      "summary": friend.summary,
      "headline": friend.headline,
      "slug": friend.slug,
      "statusId": friend.statusId,
      "imageUrl": friend.primaryImage.imageUrl,
      "imageTypeId": friend.primaryImage.imageTypeId,
      "skills": getSkillsArray(skills.skillList)
    }
  }




  //Invoked on save button click
  //this initiates the save of an existing
  //friend record
  //Parameters:
  //- e - The event
  //
  const onSave = (e) => {

    //This is necessary to prevent a non-use
    //error for the event object
    //
    console.log("onSave", e);

    if (!friend.title) {

      Toastr.warning("title need data!");
      return;
    }


    //Make the update call to the API
    //
    friendsService
      .update(friend.id, getSavePayload())
      .then(saveSuccess)
      .catch(saveError);
  }


  //Successful save of friend record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const saveSuccess = (response) => {

    //This is necessary to prevent a non-use
    //error for the response object
    //
    console.log("saveSuccess", response);

    //Let the user know the record 
    //save was successful
    //    
    Toastr.success("Your record has been updated!");
  }


  //Unsuccessful save of friend record
  //Parmeters:
  //- err - The returned Sabio API object
  //  via axios
  //
  const saveError = (err) => {

    //Build the error message
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know the record 
    //save failed
    //    
    Toastr.warning(errorString);
  }


  //Invoked on submit button click
  //this initiates the adding of a new
  //friend record
  //Parameters:
  //- e - The event object
  //
  const onSubmit = (e) => {

    //This is necessary to prevent a non-use
    //error for the event object
    //    
    console.log("onSubmit", e);

    //Make the add call to the API
    //    
    friendsService
      .add(getSubmitPayload())
      .then(submitSuccess)
      .catch(submitError);
  }


  //Successful add of friend record
  //Parmeters:
  //- response - The returned Sabio API object
  //  via axios
  //
  const submitSuccess = (response) => {

    //this toastr can run just fine on creation even
    //though the page is diverted, since the navigation
    //won't happen until after the state change, which
    //is asynchronous
    //
    Toastr.success("New friend record created!<br>Feel free to edit your new friend record.");

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setFriend(prevFriend => {

      //Make a copy of the previous state
      //
      const newUserObject = {
        ...prevFriend
      };

      //Add the record ID to the state, but also
      //change the type, which will allow redirect
      //uning navigate at the useEffect
      newUserObject.id = response.data.item;
      newUserObject.type = "FRIEND_ADD"; //<- since this has changed, the useEffect will invoke again
      newUserObject.friendUrl = "/friends/" + response.data.item;   //this is the next destination

      //This call will start a re-render of the component
      //
      return newUserObject;
    });
  }


  //Unsuccessful add of friend record
  //Parmeters:
  //- err - The returned Sabio API object
  //  via axios
  //
  const submitError = (err) => {

    //Build error response
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know that the add
    //failed
    //
    Toastr.warning(errorString);
  }


  //Runs after mount
  //It will re-run when the friend.type 
  //changes in the state
  // 
  useEffect(() => {

    //props.pingUserStatus();

    //If the type of operation we completed
    //was an "add new"
    //
    if (friend.type === "FRIEND_ADD") {

      //Prepare the new state object with the correct
      //properies of type and friendUrl
      //
      const stateObj = { ...friend, type: "FRIEND_EDIT", friendUrl: "" };

      //Use the existing state object friendUrl to redirect to
      //this same page, also passing the new state object.
      //This operation will display the new record in edit mode
      //
      navigate(friend.friendUrl, { state: stateObj });

    } else {

      //If the type is not set to ADD
      //call the get function to populate
      //the page
      //
      if (friend.id) getFriend(friend, state);

    }
  }, [friend.type]);  //<-useEffect watches for changes


  //Invoked on friends button click
  //navigates back to the friends page
  //Parameters:
  //- e - Event object
  const goToFriends = (e) => {

    //Prevents default operation 
    //of the event object
    //
    e.preventDefault();

    //Redirect to the Friends.jsx component
    //
    navigate("/friends")
  }


  //main return for display
  //
  return (
    <React.Fragment>

      <div className="container">
        <div className="mb-4 bg-light">
          <div className="container-fluid">
            <h1>{friend.id ? "Edit Friend" : "New Friend"}</h1>
          </div>
        </div>

        <form name="registrationForm" className="text-center mt-4 position-absolute top-5 start-50 translate-middle-x">
          <p><button onClick={goToFriends} type="button" className="btn btn-primary btn-sm m-1">Friends</button>
            <button onClick={friend.id ? onSave : onSubmit} type="button" className="btn btn-primary btn-sm m-1">{friend.id ? "Save" : "Submit"}</button></p>
          <input type="text" defaultValue={friend.id} id="id" name="id" className="form-control d-none" readOnly />
          <label>Title</label>
          <input type="text" id="title" value={friend.title} name="title" className="form-control" onChange={onFormFieldChange} />
          <label>Headline</label>
          <input type="text" id="headline" value={friend.headline} name="headline" className="form-control" onChange={onFormFieldChange} />
          <label>Summary</label>
          <input type="text" id="summary" value={friend.summary} name="summary" className="form-control" onChange={onFormFieldChange} />
          <label>Bio</label>
          <input type="textarea" id="bio" value={friend.bio} name="bio" className="form-control" onChange={onFormFieldChange} />
          <label>Slug</label>
          <input type="text" id="slug" value={friend.slug} name="slug" className="form-control" onChange={onFormFieldChange} />
          <label>Avatar URL</label>
          <input type="text" id="imageUrl" value={friend.primaryImage.imageUrl} name="imageUrl" className="form-control" onChange={onFormFieldChange} />
          <label>Skills</label>
          <input type="text" id="skills" value={skills.skillList} name="skills" className="form-control" onChange={onSkillChange} />
          <label>Status</label>
          <select id="statusId" name="statusId" value={friend.statusId} className="form-select" onChange={onFormFieldChange}>
            <option value="">Select a status</option>
            <option value="NotSet">Not Set</option>
            <option value="Active">Active</option>
            <option value="Deleted">Deleted</option>
            <option value="Flagged">Flagged</option>
          </select>
        </form>
      </div>

    </React.Fragment>

  );
}

export default NewEditFriends;
