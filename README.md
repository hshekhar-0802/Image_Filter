# Image_Filter
A system design project for FPGA systems which applies gradient operations to an image and displays the result on a VGA display.
<h2>Component Description</h2>
<ul>
  <li>
    <strong>MAC unit: <em></em></strong> This unit calculates the gradient value of a pixel based on the 3x3 filter used. 
  </li>
  <li>
    <strong><em>Filter unit: </em></strong> This is a component designed to contain the image data and the filter data which are used to calculate the gradient values of all the pixel one by one and once the calculation is complete, it sends the gradient data to the top component for normalization.
  </li>
  <li>
    <strong><em>State Machine: </em></strong> This is the top component which serves various functions: i) It is a state machine which coordinates all the steps in the filter operation. ii) It takes in the gradient data from the filter unit and normalizes them to fit in 0-255 range. iii) It also encompasses a VGA driver unit.
  </li>
  <li>
    <strong><em>VGA: </em></strong> This driver takes in the final value of an image in 1 clock cycle and sends it as signal to R,G,B,Hsync,Vsync pins of the BASYS FPGA board.
  </li>
</ul>
<h2>Software Requirements </h2> Xilinx Vivado (preferably 2022.2 edition).
<h2>Setting the project</h2>
<ol>
  <li>Create a new RTL project in Vivado. </li>
  <li>Add the four .vhd files as sources and the .xdc file as the constraint file.</li>
  <li>Create a distributed ROM named dist_mem_gen_0. Choose depth-4096, data width-8, port config-registered. Under RST & initialization, add the .coe file containing the image data and choose radix to be 2. </li>
  <li>Create another distributed ROM named dist_mem_gen_1. Choose depth-16, data width-8, port config- registered. Under RST & initialization, add the .coe file containing the filter data and choose radix to be 2.</li>
  <li>Now hit "Run Synthesis" followed by "Run Implementation" and then "Generate Bitstream".</li>
  <li>Connect a BASYS3 network board to the computer you are working on and connect a VGA display to the board.</li>
  <li>Now program the board using the bit file created.</li>
  <li>Voila! You have the filtered image on the screen.</li>
</ol>
<h2>COE file</h2>
<ul>
  <li>The coe file containing the image data must have pixel values as unsigned std_logic_vectors, i.e "11111111" for 255.</li>
  <li>The coe file containing the filter data must have the pixel weights as signed std_logic_vectors, i.e "11111111" for -1.</li>
</ul>
The sample image files include a lighthouse image, coins image and an image of a old man.  The filter is a simple edge detector.
