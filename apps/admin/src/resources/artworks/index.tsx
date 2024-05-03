import {
  ResourceProps,
  ListGuesser,
  EditGuesser,
  ShowGuesser,
} from "react-admin";

export const artworkResource: ResourceProps = {
  name: "artworks",
  edit: EditGuesser,
  show: ShowGuesser,
  list: ListGuesser,
};
