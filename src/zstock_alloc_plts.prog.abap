REPORT zstock_alloc_plts.

START-OF-SELECTION.

  DATA(lt_line) = zcl_alloc_plant_list=>create_default( )->run( ).

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
