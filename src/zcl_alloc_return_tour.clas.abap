CLASS zcl_alloc_return_tour DEFINITION
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


CLASS zcl_alloc_return_tour IMPLEMENTATION.

  METHOD length.
    DATA lo_dist TYPE REF TO zcl_alloc_bin_distance.

    lo_dist = NEW zcl_alloc_bin_distance( ).

    " Return strategy: the picker goes out to one stop and comes back to the start
    " before the next one, so every stop costs the round trip twice and the order
    " of the stops does not change the total.
    LOOP AT it_stops INTO DATA(ls_stop).
      rv_length = rv_length + 2
                  * lo_dist->manhattan( is_a = is_start
                                        is_b = ls_stop ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
