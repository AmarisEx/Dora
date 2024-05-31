// Initialize variables  
init_freq := LOW_FREQ         // Initial frequency for ICAP  
freq_inc := SMALL_INC         // Increment step for frequency adjustment  
max_iter := MAX_ATTEMPTS      // Maximum number of iterations to attempt  
curr_freq := init_freq        // Current frequency being tested  
max_op_freq := 0              // Highest operating frequency found  
  
// Algorithm loop to find the maximum operating frequency  
for iter := 1 to max_iter do  
    // Set the clock frequency of the ICAP via the DRP interface  
    set_freq_via_DRP(curr_freq)  
      
    // Wait for the ICAP to stabilize at the new frequency  
    stabilize_ICAP()  
      
    // Check if the ICAP is functional at the current frequency  
    if is_ICAP_functional() then  
        // Update the maximum operating frequency if a higher frequency is functional  
        max_op_freq := curr_freq  
        // Increment the current frequency for the next iteration  
        curr_freq := curr_freq + freq_inc  
    else  
        // If the current frequency is higher than the known maximum operating frequency  
        if curr_freq > max_op_freq then  
            max_op_freq := curr_freq - freq_inc  
        // Exit the loop since the maximum operating frequency has been found  
        break  
    end if  
end for  
  
// Configure the ICAP clock frequency to the maximum operating frequency found  
set_freq_via_DRP(max_op_freq)