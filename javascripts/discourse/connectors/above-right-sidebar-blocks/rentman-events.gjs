// Desktop mount: top of the right rail, above the leaderboard.
//
// `above-right-sidebar-blocks` is discourse-right-sidebar-blocks' own outlet
// and renders above every block, so the rail's `blocks` setting does not need
// to know we exist. This outlet only exists on desktop — the rail component
// returns early on mobileView — which is why there is a second mount.

import RentmanEventsList from "../../components/rentman-events-list";

<template><RentmanEventsList /></template>
