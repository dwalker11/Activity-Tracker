// JS
import 'bootstrap';

// Styles
import './sass/main.scss';

// Elm
import Elm from './elm/Main.elm';

let node = document.getElementById('app');
Elm.Main.embed(node);
