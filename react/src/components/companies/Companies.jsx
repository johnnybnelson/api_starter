//useState is for managing state, useEffect is for the useEffect function,
//which acts like the after mount function of class components, and
//useCallback is for currying, at least in this component
//
import React, { useState, useEffect, useCallback } from "react";   //add useCallback

import * as techCompaniesService from "../../services/techCompaniesService";
import Toastr from "toastr";
import Company from "../companies/Company";
import { useNavigate } from "react-router-dom";

//PAGINATION imports
//
import Pagination from 'rc-pagination';
import 'rc-pagination/assets/index.css';
import locale from "rc-pagination/lib/locale/en_US";  //pass as prop to pagination component

function Companies() {

  //init the useNavigate hook
  //
  const navigate = useNavigate();


  //set state framework
  //- Companies array will contain Company objects as defined
  //  in the Sabio API Company schema.
  //- companies Components array will contain the returned  
  //  HTML from the company component
  //- showContent - This is the toggle value for display
  //  of company records. Set to false to show no companies
  //  at startup. Currently set to true.
  //- type - This will be either COMPANIES_VIEW or COMPANIES_EDIT.
  //  When changed from COMPANIES_VIEW to COMPANIES_EDIT, the 
  //  page will be redirected to the NewEditcompanies.jsx page.
  //- editIndex - Used to indicate the index of the companies
  //  record to send to the NewEditCompanies.jsx page.
  //- editUrl - Holds the generated URL for redirect to
  //  the NewEditCompanies.jsx page. 
  //
  const [pageData, setPage] = useState({
    companies: [],
    companiesComponents: [],
    showContent: true,     //<- change this to false to have companies not show on first rendering
    type: "COMPANIES_VIEW",
    editIndex: -1,
    editUrl: "/companies/new",
    searchString: "",
    pageIndex: 0,
    pageSize: 12,
    totalCount: 0,
    totalPages: 0
  }
  );


  //If hit the  enter key in the search text
  //field, perform a company search
  //Parameters:
  //- e - the event object
  //
  const onFormKeyUp = (e) => {

    if ((pageData.type === "COMPANIES_SEARCH_A") || (pageData.type === "COMPANIES_SEARCH_B")) return;
    //I put in the extra step for readability
    //
    const enterKey = 13;
    if (e.keyCode === enterKey) companiesSearch(e);
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

      newUserObject[name] = value;  //  <- bracket notation!!!!

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newUserObject;
    });
  };


  //populate the state with the companies array
  //provided by the API call
  //Parameters:
  //- companiesArray - An array of company objects
  //
  const populateCompaniesState = (companiesArray) => {

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //
    setPage((prevState) => {

      //make a copy of the previous state
      //
      const pageDataComp = { ...prevState };

      //If this is during a search process
      //
      if ((pageData.type === "COMPANIES_SEARCH_A") || (pageData.type === "COMPANIES_SEARCH_B")) {

        //We know that the search returns null for urls, images, and companyInfo
        //We will grab a copy of that info from previous state...
        //
        let companyHolder = pageDataComp.companies;
        pageDataComp.companies = companiesArray.pagedItems;

        for (let index = 0; index < companyHolder.length; index++) {

          //
          let id = companyHolder[index].id;

          const idxOf = pageDataComp.companies.findIndex((company) => {
            let result = false;
            if (Number(company.id) === Number(id)) {
              result = true;
            };
            return result;
          });

          if (idxOf >= 0) {
            pageDataComp.companies[idxOf].urls = companyHolder[index].urls;
            pageDataComp.companies[idxOf].images = companyHolder[index].images;
            pageDataComp.companies[idxOf].contactInformation = companyHolder[index].contactInformation;
            pageDataComp.companies[idxOf].tags = companyHolder[index].tags;
            pageDataComp.companies[idxOf].friends = companyHolder[index].friends;
          }
        }
        //not during search
        //
      } else {
        pageDataComp.companies = companiesArray.pagedItems;
      }

      //Generate the HTML cards - this mapping will place
      //one company card into each array slot
      //
      pageDataComp.companiesComponents = companiesArray.pagedItems.map(createCompanyCard);

      //populate pagination properties
      //
      pageDataComp.pageIndex = companiesArray.pageIndex;
      pageDataComp.pageSize = companiesArray.pageSize;
      pageDataComp.totalCount = companiesArray.totalCount;
      pageDataComp.totalPages = companiesArray.totalPages;



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


  //Edit company
  //This is invoked from the <Company> component.
  //this function updates the state and passes
  //one company record from the companies array
  //within the state to the NewEditCompanies.jsx.
  //Parameters:
  //- thisCompany - This is a company record from a
  //  previous state that was passed to the <Company>
  //  component. This variable is a copy that is
  //  passed back and will be used used to get the 
  //  if of the record to be edited.
  //- e - The event object pass by the <Company> component. 
  //
  const editCompany = (thisCompany, e) => {

    //Grab the target URL (including the id)
    //from the event
    //
    const targetPage = e.currentTarget.dataset.page;
    let buttonId = thisCompany.id;

    //set the state
    //Parameters:
    //- An arrow function that will provide a 
    //  modifed copy of the previous state.
    //  The type, editIndex, and editUrl
    //  will be the only properties updated.
    //  Updating the type will cause useEffect
    //  to re-invoke. The type changing to
    //  COMPANY_EDIT will cause a redirect using
    //  the navigate function. See useEffect.
    //
    setPage(prevState => {

      //Get the index of the match by company id
      //
      const idxOf = prevState.companies.findIndex((company) => {
        let result = false;
        if (Number(company.id) === Number(buttonId)) {
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
      newState.type = "COMPANY_EDIT";      //<- editing this will cause useEffect to invoke again
      newState.editIndex = idxOf;
      newState.editUrl = targetPage;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return newState;
    });
  }

  //Delete company record
  //This example utilizes useCallback, which
  //wraps the function to keep it from 
  //re-rendering. It wasn't necessary here,
  //but I used it to test it.
  //Parameters:
  //- (arrow function) 
  //- e - event passed by <Company> component
  //
  const deleteCompany = useCallback((e) => {

    let buttonId = e.target.id;
    console.log("deleting: ", buttonId);
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
    techCompaniesService
      .setStatus(buttonId, "Deleted")
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

      //Display the successful delete message via Toastr
      //
      Toastr.success("The record has been deleted!");

      //set the state
      //Parameters:
      //- An arrow function that will provide a 
      //  modifed copy of the previous state.
      // 
      setPage(prevCompanies => {

        //make a copy of the previous state
        //
        const newCompaniesObject = {
          ...prevCompanies
        };

        //Copy the companies as well. You must do this to
        //prevent from making changed to the existing state.
        // 
        newCompaniesObject.companies = [...newCompaniesObject.companies];

        //Get the index of the match by company id
        //
        const idxOf = newCompaniesObject.companies.findIndex((company) => {
          let result = false;
          if (Number(company.id) === Number(id)) {
            result = true;
          };
          return result;
        });

        //If an index was generated, remove the deleted record
        //and re-generate the HTML components
        //
        if (idxOf >= 0) {
          newCompaniesObject.companies.splice(idxOf, 1);
          newCompaniesObject.companiesComponents = newCompaniesObject.companies.map(createCompanyCard);
        }
        //This returned object becomes the 
        //new state. Re-render to follow.
        //
        return newCompaniesObject;
      });
    }
  }


  //Unsuccessfully on delete
  //This is invoked if there is an error in 
  //deleting the company record using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const deleteError = (err) => {

    //Build an error string
    //
    let errorString = "<ul><li>";
    for (let i = 0; i < err.response.data.errors.length; i++) {
      errorString += err.response.data.errors[i] + "</li><li>";
    }
    errorString += "END OF LIST</li><ul>";

    //Display the error string with Toastr
    //
    Toastr.warning(errorString);
  }

  //Mapping function to build the HTML
  //for one specific company record.
  //Provides the company component the
  //following props:
  //- aCompany.id - The company id
  //- aCompany - A copy of one company
  //  from the companies array in the state.
  //- editCompany - The function to edit a
  //  company record.
  //- deleteCompany - The function to delete
  //  a company record.
  //
  const createCompanyCard = (aCompany, index) => {
    return <Company
      key={aCompany.id}
      aCompany={aCompany}
      editThisCompany={editCompany}
      deleteThisCompany={deleteCompany}
      index={index}
      pageType={pageData.type}
    >
    </Company>;
  };


  //Runs after mounting complete.
  //Rund every time items in the second 
  //parameter array are changed. In this
  //component, changes to pageData.type
  //will cause this function to re-run.
  // 
  useEffect(() => {

    console.log("useEffect");

    //if the type is COMPANY_EDIT
    //
    if (pageData.type === "COMPANY_EDIT") {

      //navigate to the edit page
      //
      const stateObj = { ...pageData.companies[pageData.editIndex], type: "COMPANY_EDIT", companyUrl: "" };
      navigate(pageData.editUrl, { state: stateObj });

    } else if ((pageData.type === "COMPANIES_SEARCH_A") || (pageData.type === "COMPANIES_SEARCH_B")) {

      //do the search
      searchForCompanies(pageData.pageIndex, pageData.pageSize, pageData.searchString);

    }
    else {

      //otherwise, get companies
      //
      getCompanies(pageData.pageIndex, pageData.pageSize);
    }
  }, [pageData.type, pageData.pageIndex, pageData.pageSize]);
  //    ^^^^^^
  //re-run the above function if the items in the array change
  //


  //Get all companies from the api
  //This function is called from the 
  //useEffect function. 
  //Parameters:
  //- index - which page
  //- size - how many records per page
  //
  const getCompanies = (index, size) => {
    techCompaniesService
      .getPage(index, size)
      .then(getSuccess)
      .catch(getError);
  }


  //Successfully retrieved the company records
  //Parameters:
  //- data - Object returned from api via axios
  //
  const getSuccess = (data) => {

    //Since we have all the company records, 
    //pass the array of companies to be processed
    //
    populateCompaniesState(data.item);
  }


  //Unsuccessfully gets company records
  //This is invoked if there is an error in 
  //retrieving of the company records using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const getError = (err) => {

    //Generate the error message
    //
    // let errorString = "<ul><li>";
    // for (let i = 0; i < err.response.data.Errors.length; i++) {
    //   errorString += err.response.data.Errors[i] + "</li><li>";
    // }
    // errorString += "END OF LIST</li><ul>";

    //Let the user know there is an error using Toastr
    //
    Toastr.warning(err);
  }


  //Navigate to create a new record
  //Invoked by clicking the Create New 
  //company button.
  //Parameters:
  //- e - Event object
  //
  const goToNew = (e) => {
    e.preventDefault();
    navigate("/companies/new")
  }


  //Perform the search
  //Parameters:
  //- index - The base index for the paginated search
  //- size -  The size of the page
  //- searchString - The typed string to search on
  //
  const searchForCompanies = (index, size, searchString) => {
    techCompaniesService
      .search(index, size, searchString)
      .then(searchSuccess)
      .catch(searchError);
  }


  //Successfully searched the company records
  //Parameters:
  //- data - Object returned from api via axios
  //
  const searchSuccess = (data) => {

    //Since we have all the company records from
    //the search, pass the array of companies to 
    //be processed
    //
    populateCompaniesState(data.item);

    //Let the user know the get was successful
    //
    //Toastr.success("Your search yielded some results!");
  }


  //Unsuccessfully searched the company records
  //This is invoked if there is an error in 
  //retrieving of the company records using the api.
  //Paremeters:
  //- err - This is an object returned by axios
  //  based on the format from the Sabio API
  //
  const searchError = (err) => {

    //Generate the error message
    //
    // let errorString = "<ul><li>";
    // for (let i = 0; i < err.response.data.errors.length; i++) {
    //   errorString += err.response.data.errors[i] + "</li><li>";
    // }
    // errorString += "END OF LIST</li><ul>";

    //Let the user know there is an error using Toastr
    //
    Toastr.warning(err);
  }

  //Invoked by the search button 
  //Begins the search functionality
  //Parameters:
  //- e - Event object
  //
  const companiesSearch = (e) => {

    console.log("companiesSearch", e);
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
      pageDataComp.type = (pageDataComp.type === "COMPANIES_SEARCH_A") ? "COMPANIES_SEARCH_B" : "COMPANIES_SEARCH_A";
      pageDataComp.pageIndex = 0;

      //This returned object becomes the 
      //new state. Re-render to follow.
      //
      return pageDataComp;
    });
  }

  //Clears the search text and 
  //reloads the original companies render
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
      pageDataComp.type = "COMPANIES_VIEW";
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
            <h1>Companies</h1>
          </div>
        </div>
        <div className="companies row">
          <p><button onClick={toggleShow} type="button" className="btn btn-primary btn-sm m-1">Toggle Content Display</button>
            <button onClick={goToNew} type="button" className="btn btn-primary btn-sm m-1">Add New Company</button>
            <button id="clearSearch" onClick={clearSearch} className="btn btn-primary btn-sm m-1" name="clearSearch">Clear search</button>
            <button id="search" onClick={companiesSearch} className={((pageData.type === "COMPANIES_SEARCH_A") || (pageData.type === "COMPANIES_SEARCH_B")) ? "d-none" : "btn btn-primary btn-sm m-1"} name="search">Search</button>
            <input type="text" id="searchString" onKeyUp={onFormKeyUp} onChange={onFormFieldChange} value={pageData.searchString} name="searchString" style={{ width: "260px" }} />

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
              <option value="6">6</option>
              <option value="12">12</option>
              <option value="18">18</option>
              <option value="24">24</option>
            </select>
          </td></tr></table>

          {pageData.showContent && pageData.companiesComponents}

        </div>
      </div>
    </React.Fragment>
  );
}

export default Companies;
