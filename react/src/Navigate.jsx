import React from "react";
import { useNavigate } from "react-router-dom";

function Navigate() {

  const navigate = useNavigate();  //comes with the useNavigate hook

  const goToPage = (e) => {
    //
    console.log(e.currentTarget.dataset.page);
    navigate(e.currentTarget.dataset.page);   //goes to url
  }


  return (
    <React.Fragment>
      <div className="position-relative">
        <div className="btn-group" role="group" aria-label="Basic example">
          <button type="button" id="pg1" data-page="/page1" className="btn btn-primary" onClick={goToPage}>
            Go to Page 1
          </button>
          <button type="button" id="pg2" data-page="/page2" className="btn btn-primary" onClick={goToPage}>
            Go to Page 2
          </button>
          <button type="button" id="pg3" data-page="/page3" className="btn btn-primary" onClick={goToPage}>
            Go to Page 3
          </button>
          <button type="button" id="home" data-page="/" className="btn btn-primary" onClick={goToPage}>
            Go Home
          </button>
        </div>
      </div>
    </React.Fragment>
  );
}

export default Navigate;
