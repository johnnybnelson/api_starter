//Friends functional component is called from App.jsx from
//a route with /friends as the identifier. This component
//displays a listing of friends in Bootstrap card format.
//Friends has one child component, Person, that is called 
//via the element tag, <Person>, and one child component
//that is redirected to at either /friends/new or 
//friends/friendId. Partial state is passed to Person via
//props, while partial state is passed to NewEditFriends.jsx
//through the Navigate function.
//
import React, { useState, useEffect, useCallback } from "react";
import * as friendsService from "../../services/friendsService";
import Toastr from "toastr";
import Person from "../person/Person";
import { useNavigate } from "react-router-dom";
import debug from "sabio-debug"; //Added for prod dev class

//PAGINATION imports
//
import Pagination from 'rc-pagination';
import 'rc-pagination/assets/index.css';
import locale from "rc-pagination/lib/locale/en_US";  //pass as prop to pagination component

function Friends() {


  const _logger = debug.extend("Friends");   //Added for prod dev class

  //init the useNavigate hook
  //
  const navigate = useNavigate();


  //set state framework
  //- friends array will contain friend objects as defined
  //  in the Sabio API friend schema.
  //- peopleComponents array will contain the returned  
  //  HTML from the Person component
  //- showContent - This is the toggle value for display
  //  of friend records. Set to false to show no friends
  //  at startup. Currently set to true.
  //- type - This will be either FRIENDS_VIEW or FRIENDS_EDIT.
  //  When changed from FRIENDS_VIEW to FRIENDS_EDIT, the 
  //  page will be redirected to the NewEditFriends.jsx page.
  //- editIndex - Used to indicate the index of the friends
  //  record to send to the NewEditFriends.jsx page.
  //- editUrl - Holds the generated URL for redirect to
  //  the NewEditFriends.jsx page. 
  //
  const [pageData, setPage] = useState({
    friends: [],
    peopleComponents: [],
    showContent: true,     //<- change this to false to have friends not show on first rendering
    type: "FRIENDS_VIEW",
    editIndex: -1,
    editUrl: "/friends/new",
    searchString: "",
    pageIndex: 0,
    pageSize: 10,
    totalCount: 0,
    totalPages: 0
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
    setPage(prevState => {

      // copy the previous state
      //
      const newUserObject = {
        ...prevState
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


  //populate the state with the friends array
  //provided by the API call
  //Parameters:
  //- friendsArray - An array of friend objects
  //
  const populateFriendsState = (friendsArray) => {

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //replace the entire friends array
      //
      //debugger;
      pageDataComp.friends = friendsArray.pagedItems;

      //Generate the HTML cards - this mapping will place
      //one friend card into each array slot
      //
      pageDataComp.peopleComponents = friendsArray.pagedItems.map(createFriendCard);

      //populate pagination properties
      //
      pageDataComp.pageIndex = friendsArray.pageIndex;
      pageDataComp.pageSize = friendsArray.pageSize;
      pageDataComp.totalCount = friendsArray.totalCount;
      pageDataComp.totalPages = friendsArray.totalPages;


      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });

  };


  //Simple toggle for showing content
  //Parameters:
  //- e - This is the event object
  //
  const toggleShow = (e) => {
    e.preventDefault();
    e.stopPropagation();

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The only thing modified will be the 
    //  showContent property.  
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.showContent = !(prevState.showContent);

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };


  //Edit friend
  //This is invoked from the <Person> component.
  //this function updates the state and passes
  //one friend record from the friends array
  //within the state to the NewEditFriends.jsx.
  //Parameters:
  //- thisPerson - This is a friend record from a
  //  previous state that was passed to the <Person>
  //  component. This variable is a copy that is
  //  passed back and will be used used to get the 
  //  if of the record to be edited.
  //- e - The event object pass by the <Person> component. 
  //
  const editFriend = (thisPerson, e) => {

    //Grab the target URL (including the id)
    //from the event
    //
    const targetPage = e.currentTarget.dataset.page;

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The type, editIndex, and editUrl
    //  will be the only properties updated.
    //  Updating the type will cause useEffect
    //  to re-invoke. The type changing to
    //  FRIEND_EDIT will cause a redirect using
    //  the navigate function. See useEffect.
    //
    setPage(prevState => {

      //Get the index of the match by friend id
      //
      const idxOf = prevState.friends.findIndex((person) => {
        let result = false;
        if (Number(person.id) === Number(thisPerson.id)) {
          result = true;
        };
        return result;
      });

      if (!(idxOf >= 0)) return false;    //if no match, exit function

      //Get a copy of the previous state
      //
      const newState = { ...prevState };

      //Set type, index, and url
      //
      newState.type = "FRIEND_EDIT";      //<- editing this will cause useEffect to invoke again
      newState.editIndex = idxOf;
      newState.editUrl = targetPage;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newState;
    });
  }

  //Delete friend record
  //This example utilizes useCallback, which
  //wraps the function to keep it from 
  //re-rendering. It wasn't necessary here,
  //but I used it to test it.
  //Parameters:
  //- (arrow function) 
  //- person - This is a friend record from a
  //  previous state that was passed to the <Person>
  //  component. This variable is a copy that is
  //  passed back and will be used used to get the 
  //  if of the record to be deleted.
  //- e - event passed by <Person> component
  //
  const deleteFriend = useCallback((person, e) => {

    let buttonId = e.target.id;

    //Currying step 2 - invoke the function with the 
    //variable you want to be curried (id in this case)
    //This is assigned to a variable. At this point, the
    //currying function is only partially invoked
    //
    const handler = getDeleteSuccessHandler(buttonId);

    //Currying step 3 - Invoking "handler" 
    //upon success will complete the function
    //and the id will already be inside the 
    //curried function
    //
    friendsService
      .deleteById(buttonId)
      .then(handler)  //<- the function that completes the currying operation
      .catch(deleteError);
  }, []);


  //Success on delete - invoked if there are no
  //errors when completing the delete using the api
  //Currying example - Step 1 - define function
  //Since the delete API call does not return
  //the ID of the deleted record, this method
  //of currying carries over the ID to be used
  //when needed.
  //See anything in code with //Currying in the 
  //comments
  //
  const getDeleteSuccessHandler = (id) => {

    //This returned function does not get executed
    //until step 3. The id will already be here 
    //from step 1
    //
    return () => {

      _logger("Delete Successful:" + id);  //added during prod dev class

      //Display the successful delete message via Toastr
      //
      Toastr.success("The record has been deleted!");

      //set the state
      //Parameters:
      //- An arrow function that will provide a 
      //  modifed copy of the previous state.
      // 
      setPage(prevFriends => {

        //make a copy of the previous state
        //
        const newFriendsObject = {
          ...prevFriends
        };

        //Copy the friends as well. You must do this to
        //prevent from making changed to the existing state.
        // 
        newFriendsObject.friends = [...newFriendsObject.friends];

        //Get the index of the match by friend id
        //
        const idxOf = newFriendsObject.friends.findIndex((person) => {
          let result = false;
          if (Number(person.id) === Number(id)) {
            result = true;
          };
          return result;
        });

        //If an index was generated, remove the deleted record
        //and re-generate the HTML components
        //
        if (idxOf >= 0) {
          newFriendsObject.friends.splice(idxOf, 1);
          newFriendsObject.peopleComponents = newFriendsObject.friends.map(createFriendCard);
        }
        //This returned object becomes the 
        //new state. Re-render to follow.
        //
        return newFriendsObject;
      });
    }
  }


  //Unsuccessfully on delete
  //This is invoked if there is an error in 
  //deleting the friend record using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const deleteError = (err) => {

    console.log(err);

    //Build an error string
    //
    // let errorString = "<ul><li>";
    // for (let i = 0; i < err.response.data.errors.length; i++) {
    //   errorString += err.response.data.errors[i] + "</li><li>";
    // }
    // errorString += "END OF LIST</li><ul>";

    // //Display the error string with Toastr
    // //
    // Toastr.warning(errorString);
  }


  //Mapping function to build the HTML
  //for one specific friend record.
  //Provides the Person component the
  //following props:
  //- aFriend.id - The friend id
  //- aFriend - A copy of one friend
  //  from the friends array in the state.
  //- editFriend - The function to edit a
  //  friend record.
  //- deleteFriend - The function to delete
  //  a friend record.
  //
  const createFriendCard = (aFriend) => {
    return <Person
      key={aFriend.id}
      aPerson={aFriend}
      editThisFriend={editFriend}
      deleteThisFriend={deleteFriend}>
    </Person>;
  };


  //Runs after mounting complete.
  //Rund every time items in the second 
  //parameter array are changed. In this
  //component, changes to pageData.type
  //will cause this function to re-run.
  // 
  useEffect(() => {

    console.log("useEffect");

    //props.pingUserStatus();

    //if the type is FRIEND_EDIT
    //
    if (pageData.type === "FRIEND_EDIT") {

      //navigate to the edit page
      //
      const stateObj = { ...pageData.friends[pageData.editIndex], type: "FRIEND_EDIT", friendUrl: "" };
      navigate(pageData.editUrl, { state: stateObj });

    } else if ((pageData.type === "FRIENDS_SEARCH_A") || (pageData.type === "FRIENDS_SEARCH_B")) {

      //do the search
      searchForFriends(pageData.pageIndex, pageData.pageSize, pageData.searchString);

    }
    else {

      //otherwise, get friends
      //
      getFriends(pageData.pageIndex, pageData.pageSize);
    }
  }, [pageData.type, pageData.pageIndex, pageData.pageSize]);
  //    ^^^^^^
  //re-run the above function if the items in the array change
  //


  //Get all friends from the api
  //This function is called from the 
  //useEffect function. 
  //
  const getFriends = (index, size) => {
    friendsService
      .getPage(index, size)
      .then(getSuccess)
      .catch(getError);
  }


  //Successfully retrieved the friend records
  //Parameters:
  //- data - Object returned from api via axios
  //
  const getSuccess = (data) => {

    _logger("Get Friends Successful! " + data.item.pagedItems.length + " records loaded.");  //added during prod dev class

    //Since we have all the friend records, 
    //pass the array of friends to be processed
    //
    populateFriendsState(data.item);
    // populateFriendsState(data.items);

    //Let the user know the get was successful
    //
    //Toastr.success("Your friends list has rendered!");


  }


  //Unsuccessfully gets friend records
  //This is invoked if there is an error in 
  //retrieving of the friend records using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const getError = (err) => {

    console.log(err);

    //Generate the error message
    //
    // let errorString = "<ul><li>";
    // for (let i = 0; i < err.response.data.Errors.length; i++) {
    //   errorString += err.response.data.Errors[i] + "</li><li>";
    // }
    // errorString += "END OF LIST</li><ul>";

    // //Let the user know there is an error using Toastr
    // //
    // Toastr.warning(errorString);
  }


  //Navigate to create a new record
  //Invoked by clicking the Create New 
  //Friend button.
  //Parameters:
  //- e - Event object
  //
  const goToNew = (e) => {
    e.preventDefault();
    navigate("/friends/new")
  }


  //Perform the search
  //Parameters:
  //- index - The base index for the paginated search
  //- size -  The size of the page
  //- searchString - The typed string to search on
  //
  const searchForFriends = (index, size, searchString) => {
    friendsService
      .search(index, size, searchString)
      .then(searchSuccess)
      .catch(searchError);
  }


  //Successfully searched the friend records
  //Parameters:
  //- data - Object returned from api via axios
  //
  const searchSuccess = (data) => {

    _logger("Search results! " + data.item.pagedItems.length + " matched records loaded.");  //added during prod dev class

    //Since we have all the friend records from
    //the search, pass the array of friends to 
    //be processed
    //
    populateFriendsState(data.item);

    //Let the user know the get was successful
    //
    Toastr.success("Your search yielded some results!");
  }


  //Unsuccessfully searched the friend records
  //This is invoked if there is an error in 
  //retrieving of the friend records using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the API
  //
  const searchError = (err) => {

    //Generate the error message
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Let the user know there is an error using Toastr
    //
    Toastr.warning(errorString);
  }

  //Invoked by the search button 
  //Begins the search functionality
  //Parameters:
  //- e - Event object
  //
  const friendsSearch = (e) => {

    console.log("friendsSearch", e);
    if (!pageData.searchString) {
      Toastr.warning("Please enter a search string!");
      return;
    }

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The only thing modified will be the 
    //  showContent property.  
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Set type to search. Toggles between two searches, A and B
      //to allow multiple searches in a row
      //
      pageDataComp.type = (pageDataComp.type === "FRIENDS_SEARCH_A") ? "FRIENDS_SEARCH_B" : "FRIENDS_SEARCH_A";
      pageDataComp.pageIndex = 0;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });



  }

  //Clears the search text and 
  //reloads the original friends render
  //Parameters:
  //- e - Event object
  //
  const clearSearch = (e) => {

    console.log("clearSearch", e);

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The only thing modified will be the 
    //  showContent property.  
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.type = "FRIENDS_VIEW";
      pageDataComp.searchString = "";

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });

  }


  //Invoked by the <Pagination> component
  //with the onChange method.
  //Parameters: 
  //- page - The page of the destination in the 
  //  pagination. If i were already on page 2, 
  //  then clicked "3" or the > link, the page
  //  parameter would be 3.
  //
  const onPageChange = page => {
    console.log("onChange", page);
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.pageIndex = page - 1;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };


  //Invoked by the <Pagination> component
  //with the onChange method.
  //Parameters: 
  //- page - The page of the destination in the 
  //  pagination. If i were already on page 2, 
  //  then clicked "3" or the > link, the page
  //  parameter would be 3.
  //
  const onPageSizeChange = (e) => {
    console.log("onPageSizeChange", e);
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //Toggle the showContent boolean
      //
      pageDataComp.pageSize = e.target.value;
      pageDataComp.pageIndex = 0;
      //pageDataComp.type = "FRIENDS_VIEW";
      //pageDataComp.searchString = "";

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  };

  return (
    <React.Fragment>
      <div className="container">
        <div className="mb-4 bg-light">
          <div className="container-fluid">
            <h1>Friends</h1>
          </div>
        </div>
        <div className="friends row">
          <p><button onClick={toggleShow} type="button" className="btn btn-primary btn-sm m-1">Toggle Content Display</button>
            <button onClick={goToNew} type="button" className="btn btn-primary btn-sm m-1">Add New Friend</button>

            <button id="clearSearch" onClick={clearSearch} className="btn btn-primary btn-sm m-1" name="clearSearch">Clear search</button>
            <button id="search" onClick={friendsSearch} className="btn btn-primary btn-sm m-1" name="search">Search</button>
            <input type="text" id="searchString" onChange={onFormFieldChange} value={pageData.searchString} name="searchString" style={{ width: "260px" }} />

          </p>

          <table className="table"><tr><td width="15%">
            <Pagination
              onChange={onPageChange}
              current={pageData.pageIndex + 1}
              total={pageData.totalCount}
              locale={locale}
              pageSize={pageData.pageSize}
            ></Pagination>

            Page Size:
            <select onChange={onPageSizeChange} value={pageData.pageSize}>
              <option value="5">5</option>
              <option value="10">10</option>
              <option value="15">15</option>
              <option value="20">20</option>
            </select>
          </td></tr></table>

          {pageData.showContent && pageData.peopleComponents}

        </div>
      </div>
    </React.Fragment>
  );
}

export default Friends;
