var slider = document.getElementById("team-pricing-slider");
var output = document.getElementById("team-seats");
var pricing = document.getElementById ("team-pricing");
var quantity = document.getElementById("quantity-form");
output.innerHTML = slider.value; // Display the default slider value

// Update the current slider value (each time you drag the slider handle)
slider.oninput = function() {
    output.innerHTML = this.value;
    pricing.innerHTML = this.value*200;
    quantity.value = this.value;
};
