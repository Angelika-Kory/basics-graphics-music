`include "config.svh"

module lab_top
# (
    parameter  clk_mhz       = 50,
               w_key         = 4,
               w_sw          = 8,
               w_led         = 8,
               w_digit       = 8,
               w_gpio        = 100,

               screen_width  = 640,
               screen_height = 480,

               w_red         = 4,
               w_green       = 4,
               w_blue        = 4,

               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)
(
    input                        clk,
    input                        slow_clk,
    input                        rst,

    // Keys, switches, LEDs

    input        [w_key   - 1:0] key,
    input        [w_sw    - 1:0] sw,
    output logic [w_led   - 1:0] led,

    // A dynamic seven-segment display

    output logic [          7:0] abcdefgh,
    output logic [w_digit - 1:0] digit,

    // Graphics

    input        [w_x     - 1:0] x,
    input        [w_y     - 1:0] y,

    output logic [w_red   - 1:0] red,
    output logic [w_green - 1:0] green,
    output logic [w_blue  - 1:0] blue,

    // Microphone, sound output and UART

    input        [         23:0] mic,
    output       [         15:0] sound,

    input                        uart_rx,
    output                       uart_tx,

    // General-purpose Input/Output

    inout        [w_gpio  - 1:0] gpio
);

    //------------------------------------------------------------------------

       assign abcdefgh   = '0;
       assign digit      = '0;
       assign red        = '0;
       assign green      = '0;
       assign blue       = '0;
       assign sound      = '0;
       assign uart_tx    = '1;

    //------------------------------------------------------------------------

    // Exercise 1: Free running counter.
    // How do you change the speed of LED blinking?
    // Try different bit slices to display.

    localparam w_cnt = $clog2 (clk_mhz * 1000 * 1000); // 50 млн тактов в секунду, для этого надо 26 бита

    logic [w_cnt - 1:0] cnt; // объявление регистра

    always_ff @ (posedge clk or posedge rst) // ф-я для логики на триггерах, поседж тк передний фронт
        if (rst)
            cnt <= '0;
        else
            cnt <= cnt + 1'd1;

    assign led = cnt [$left (cnt) -: w_led]; // срез битов

    // Exercise 2: Key-controlled counter.
    // Comment out the code above.
    // Uncomment and synthesize the code below.
    // Press the key to see the counter incrementing.
    //
    // Change the design, for example:
    //
    // 1. One key is used to increment, another to decrement.
wire any_key0 = key[0];
wire any_key1 = key[1];

logic any_key_r0;
logic any_key_r1;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        any_key_r0 <= '0;
        any_key_r1 <= '0;
    end else begin
        any_key_r0 <= any_key0;
        any_key_r1 <= any_key1;
    end
end

wire any_key_pressed0 = ~any_key0 & any_key_r0;
wire any_key_pressed1 = ~any_key1 & any_key_r1;

    logic [w_led - 1:0] cnt;

always_ff @(posedge clk or posedge rst)
    if (rst)
        cnt <= '0;
    else if (any_key_pressed0)
        cnt <= cnt + 1'd1;
    else if (any_key_pressed1)
        cnt <= cnt - 1'd1;

    assign led = w_led' (cnt);

    // 2. Two counters controlled by different keys
    // displayed in different groups of LEDs.
wire any_key0 = key[0];
wire any_key1 = key[1];

logic any_key_r0;
logic any_key_r1;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        any_key_r0 <= '0;
        any_key_r1 <= '0;
    end else begin
        any_key_r0 <= any_key0;
        any_key_r1 <= any_key1;
    end
end

wire any_key_pressed0 = ~any_key0 & any_key_r0;
wire any_key_pressed1 = ~any_key1 & any_key_r1;

    logic [3:0] cnt0;
    logic [3:0] cnt1;

// Первый счётчик
always_ff @(posedge clk or posedge rst)
    if (rst)
        cnt0 <= '0;
    else if (any_key_pressed0)
        cnt0 <= cnt0 + 1'd1;

// Второй счётчик
always_ff @(posedge clk or posedge rst)
    if (rst)
        cnt1 <= '0;
    else if (any_key_pressed1)
        cnt1 <= cnt1 + 1'd1;

assign led[3:0] = cnt0;
assign led[7:4] = cnt1;    

////////////////////////////// ТЕОРИЯ///////////////////////////////////////////////////////////////
    wire any_key = | key; //если хотя бы одна кнопка активна any_key = 1, унитарное или, активное состояние кнопки 1.
// any_key - текущее состояние кнопок, any_key_r- зарегистрированное, то есть сохранённое на такте, состояние кнопок
    logic any_key_r; // объявляется переменная, запоминает состояние предыдущего такта

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            any_key_r <= '0;
        else
            any_key_r <= any_key;

    wire any_key_pressed = ~ any_key & any_key_r; // определяется отпускание кнопки

    logic [w_led - 1:0] cnt; // диапазон битов счётчика, четырехбитный счетчик значить из 8 вычитаем 1 получаем 7, 7:0

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            cnt <= '0;
        else if (any_key_pressed)
            cnt <= cnt + 1'd1;

    assign led = w_led' (cnt); // суть в том, что мы нажимаем кнопку any_key, any_key_r запоминает выбор, потом отпускаем
// any_key_pressed запоминает когда кнопку отпустилась пишет 1, счетчик cnt включает светодиод


endmodule
