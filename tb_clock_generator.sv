`timescale 1ns/1ps

module tb;

  //--------------------------------------------------
  // Base Clock
  //--------------------------------------------------
  logic clk = 0;

  // 100 MHz reference clock
  always #5 clk = ~clk;

  //--------------------------------------------------
  // Generated Clock
  //--------------------------------------------------
  logic clk_out = 0;

  //--------------------------------------------------
  // Dump Waveform
  //--------------------------------------------------
  initial begin
    $dumpfile("clock_generator.vcd");
    $dumpvars(0, tb);
  end

  //--------------------------------------------------
  // Clock Generator Task
  //--------------------------------------------------
  task automatic clk_generator(
    input real freq_hz,
    input real duty_cycle,
    input real phase_ns
  );

    real period_ns;
    real ton;
    real toff;

    begin

      //------------------------------------------------
      // Timing Calculations
      //------------------------------------------------
      period_ns = 1_000_000_000.0 / freq_hz;

      ton  = period_ns * duty_cycle;
      toff = period_ns - ton;

      //------------------------------------------------
      // Debug Information
      //------------------------------------------------
      $display("--------------------------------");
      $display("Clock Generator Configuration");
      $display("--------------------------------");
      $display("Frequency   = %0f Hz", freq_hz);
      $display("Period      = %0f ns", period_ns);
      $display("Duty Cycle  = %0f %%", duty_cycle * 100);
      $display("TON         = %0f ns", ton);
      $display("TOFF        = %0f ns", toff);
      $display("Phase Delay = %0f ns", phase_ns);
      $display("--------------------------------");

      //------------------------------------------------
      // Synchronize to Reference Clock
      //------------------------------------------------
      @(posedge clk);

      //------------------------------------------------
      // Apply Phase Delay
      //------------------------------------------------
      #phase_ns;

      //------------------------------------------------
      // Generate Clock Forever
      //------------------------------------------------
      forever begin
        clk_out = 1;
        #ton;

        clk_out = 0;
        #toff;
      end

    end

  endtask

  //--------------------------------------------------
  // Start Clock Generator
  //--------------------------------------------------
  initial begin

    fork
      clk_generator(
        100_000_000, // 100 MHz
        0.5,         // 50% duty cycle
        2            // 2 ns phase shift
      );
    join_none

  end

  //--------------------------------------------------
  // End Simulation
  //--------------------------------------------------
  initial begin
    #200;
    $finish;
  end

endmodule
