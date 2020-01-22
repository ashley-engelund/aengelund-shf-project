// Utility functions used in checklist views (UserChecklist, AdminOnly::MasterChecklist

"use strict";

const defaultHideClass = "hide";
const defaultShowClass = "inherit";


function showElementWithClass(element, showClass = defaultShowClass, hideClass = defaultHideClass) {
  replaceClass(element, hideClass, showClass);
}

function hideElementWithClass(element, showClass = defaultShowClass, hideClass = defaultHideClass) {
  replaceClass(element, showClass, hideClass);
}

function replaceClass(element, existingClass, replacingClass) {
  if (element !== null) {

    // check to see if .classList is supported by the browser
    if (element.classList) {
      element.classList.remove(existingClass);
      element.classList.add(replacingClass);
    } else {
      // This handles IE 9 and older
      var classes = element.className.split(" ");
      var i = classes.indexOf(existingClass);

      if (i >= 0) {
        // splice: (remove element start index, number to remove, element to add)
        classes.splice(i, 1, replacingClass);
      } else {
        classes.push(replacingClass);
      }
      element.className = classes.join(" ");
    }
  }
}


function addClass(element, newClass) {
  if (element !== null) {

    // check to see if .classList is supported by the browser
    if (element.classList) {
      element.classList.add(newClass);
    } else {
      // This handles IE 9 and older
      element.className = element.className + " " + newClass;
    }
  }
}
