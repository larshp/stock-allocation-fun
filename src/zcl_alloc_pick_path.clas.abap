CLASS zcl_alloc_pick_path DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS length
      IMPORTING
        is_start         TYPE zcl_alloc_bin_coord=>ty_coord
        it_stops         TYPE zcl_alloc_bin_distance=>ty_coord_tt
      RETURNING
        VALUE(rv_length) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pick_path IMPLEMENTATION.

  METHOD length.
    DATA lo_dist TYPE REF TO zcl_alloc_bin_distance.
    DATA ls_prev TYPE zcl_alloc_bin_coord=>ty_coord.

    lo_dist = NEW zcl_alloc_bin_distance( ).
    ls_prev = is_start.

    " The path length is the sum of the legs between the start and the stops in
    " the order given, so the caller decides the route and this only measures it.
    LOOP AT it_stops INTO DATA(ls_stop).
      rv_length = rv_length + lo_dist->manhattan( is_a = ls_prev
                                                  is_b = ls_stop ).
      ls_prev = ls_stop.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
