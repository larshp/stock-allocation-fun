INTERFACE zif_alloc_config PUBLIC.

  "! How allocation behaves in one plant. Everything a night job would
  "! otherwise have to carry in a job variant, in one place per plant.
  TYPES:
    BEGIN OF ty_config,
      werks        TYPE mard-werks,
      fair_share   TYPE abap_bool,
      horizon_days TYPE i,
      lgort        TYPE mard-lgort,
      cap_percent  TYPE i,
      keep_days    TYPE i,
      planned      TYPE abap_bool,
      whole_units  TYPE abap_bool,
    END OF ty_config.

  "! <p class="shorttext synchronized">Settings that apply to allocation in a plant</p>
  "!
  "! A plant nobody has configured is answered with the defaults rather than
  "! with an error: allocation works out of the box, and Customizing only has
  "! to say what differs from it.
  "!
  "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
  "! @parameter rs_config | <p class="shorttext synchronized">Settings, defaults where nothing is set</p>
  METHODS for_plant
    IMPORTING
      iv_werks         TYPE mard-werks
    RETURNING
      VALUE(rs_config) TYPE ty_config.

ENDINTERFACE.
