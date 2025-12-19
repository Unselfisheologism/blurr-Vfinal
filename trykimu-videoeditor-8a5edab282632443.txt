Directory structure:
└── trykimu-videoeditor/
    ├── README.md
    ├── CODE_OF_CONDUCT.md
    ├── components.json
    ├── CONTRIBUTING.md
    ├── docker-compose.yml
    ├── Dockerfile.backend
    ├── Dockerfile.frontend
    ├── eslint.config.js
    ├── LICENSE-AGPL3.md
    ├── LICENSE.md
    ├── nginx.conf
    ├── package.json
    ├── react-router.config.ts
    ├── SECURITY.md
    ├── tsconfig.json
    ├── vite.config.ts
    ├── .dockerignore
    ├── .env.example
    ├── .prettierignore
    ├── .prettierrc
    ├── app/
    │   ├── app.css
    │   ├── NotFound.tsx
    │   ├── root.tsx
    │   ├── routes.ts
    │   ├── components/
    │   │   ├── chat/
    │   │   │   └── ChatBox.tsx
    │   │   ├── editor/
    │   │   │   └── LeftPanel.tsx
    │   │   ├── media/
    │   │   │   ├── TextEditor.tsx
    │   │   │   └── Transitions.tsx
    │   │   ├── redirects/
    │   │   │   └── mediaBinLoader.ts
    │   │   ├── timeline/
    │   │   │   ├── DimensionControls.tsx
    │   │   │   ├── MediaActionButtons.tsx
    │   │   │   ├── MediaBin.tsx
    │   │   │   ├── MediaBinPage.tsx
    │   │   │   ├── MediaBinRoute.tsx
    │   │   │   ├── RenderActionButtons.tsx
    │   │   │   ├── RenderStatus.tsx
    │   │   │   ├── Scrubber.tsx
    │   │   │   ├── TimelineControls.tsx
    │   │   │   ├── TimelineRuler.tsx
    │   │   │   ├── TimelineTitle.tsx
    │   │   │   ├── TimelineTracks.tsx
    │   │   │   ├── TrackActionButton.tsx
    │   │   │   ├── TransitionOverlay.tsx
    │   │   │   └── types.ts
    │   │   └── ui/
    │   │       ├── alert-dialog.tsx
    │   │       ├── AuthOverlay.tsx
    │   │       ├── badge.tsx
    │   │       ├── button.tsx
    │   │       ├── card-hover-effect.tsx
    │   │       ├── card.tsx
    │   │       ├── drawer.tsx
    │   │       ├── dropdown-menu.tsx
    │   │       ├── following-pointer.tsx
    │   │       ├── Footer.tsx
    │   │       ├── glowing-effect.tsx
    │   │       ├── input.tsx
    │   │       ├── KimuLogo.tsx
    │   │       ├── label.tsx
    │   │       ├── MarketingFooter.tsx
    │   │       ├── menubar.tsx
    │   │       ├── modal.tsx
    │   │       ├── Navbar.tsx
    │   │       ├── ProfileMenu.tsx
    │   │       ├── progress.tsx
    │   │       ├── resizable.tsx
    │   │       ├── scroll-area.tsx
    │   │       ├── select.tsx
    │   │       ├── separator.tsx
    │   │       ├── skeleton.tsx
    │   │       ├── sonner.tsx
    │   │       ├── switch.tsx
    │   │       ├── tabs.tsx
    │   │       ├── text-hover-effect.tsx
    │   │       ├── ThemeProvider.tsx
    │   │       ├── tooltip.tsx
    │   │       └── video-controls.tsx
    │   ├── hooks/
    │   │   ├── useAuth.ts
    │   │   ├── useMediaBin.ts
    │   │   ├── useRenderer.ts
    │   │   └── useRuler.ts
    │   ├── lib/
    │   │   ├── assets.repo.ts
    │   │   ├── auth.client.ts
    │   │   ├── auth.server.ts
    │   │   ├── migrate.ts
    │   │   ├── projects.repo.ts
    │   │   ├── timeline.store.ts
    │   │   └── utils.ts
    │   ├── routes/
    │   │   ├── api.assets.$.tsx
    │   │   ├── api.auth.$.tsx
    │   │   ├── api.projects.$.tsx
    │   │   ├── api.storage.$.tsx
    │   │   ├── home.tsx
    │   │   ├── learn.tsx
    │   │   ├── login.tsx
    │   │   ├── marketplace.tsx
    │   │   ├── privacy.tsx
    │   │   ├── profile.tsx
    │   │   ├── project.$id.tsx
    │   │   ├── projects.tsx
    │   │   ├── roadmap.tsx
    │   │   └── terms.tsx
    │   ├── utils/
    │   │   ├── api.ts
    │   │   ├── llm-handler.ts
    │   │   └── uuid.ts
    │   ├── video-compositions/
    │   │   ├── DragDrop.tsx
    │   │   └── VideoPlayer.tsx
    │   └── videorender/
    │       ├── Composition.tsx
    │       ├── index.ts
    │       └── videorender.ts
    ├── backend/
    │   ├── README.md
    │   ├── Dockerfile
    │   ├── main.py
    │   ├── pyproject.toml
    │   ├── schema.py
    │   ├── .env.example
    │   └── .python-version
    ├── migrations/
    │   ├── 000_init.sql
    │   ├── 001_assets.sql
    │   └── 002_projects.sql
    └── .github/
        ├── PULL_REQUEST_TEMPLATE.md
        └── workflows/
            └── lint.yml

================================================
FILE: README.md
================================================
<samp>
  
<h1>Kimu</h1>
<p>Copilot for Video Editing.</p>
<br />

> [!NOTE]  
> The application is under active development. This is an early MVP. Please join the [Discord server](https://discord.gg/GSknuxubZK) if you're going to run it.

<br />

<p align="center">
  <img src="public/screenshot-app.png" alt="React Video Editor Screenshot">
</p>
<p align="center">An open-source alternative to Capcut, Canva, and RVE.</p>
</samp>

## ✨Features

- 🎬Non Linear Video Editing
- 🔀Multi-track Support
- 👀Live Preview
- 📤Export Video

## 🐋Deployment

```
git clone https://github.com/robinroy03/videoeditor.git
cd videoeditor
docker compose up
```

## 🧑‍💻Development

```
pnpm i
pnpm run dev (frontend)
pnpm dlx tsx app/videorender/videorender.ts (backend)
uv run backend/main.py
flip `isProduction` to `false` in `/app/utils/api.ts`

You will also require a GEMINI_API_KEY if you want to use AI.
```

## 📃TODO

We have a lot of work! For starters, we plan to integrate all Remotion APIs. I'll add a proper roadmap soon. Join the [Discord Server](https://discord.com/invite/GSknuxubZK) for updates and support.

## ❤️Contribution

We would love your contributions! ❤️ Check the [contribution guide](CONTRIBUTING.md).

## 📜License

This project is licensed under a dual-license. Refer to [LICENSE](LICENSE.md) for details. The [Remotion license](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md) also applies to the relevant parts of the project.



================================================
FILE: CODE_OF_CONDUCT.md
================================================
Please be chill.


================================================
FILE: components.json
================================================
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "app/app.css",
    "baseColor": "gray",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "~/components",
    "utils": "~/lib/utils",
    "ui": "~/components/ui",
    "lib": "~/lib",
    "hooks": "~/hooks"
  },
  "iconLibrary": "lucide"
}


================================================
FILE: CONTRIBUTING.md
================================================
# How to Contribute

We welcome all contributions to this project! Here are some simple ways you can help:

## Join Our Community
Join our [Discord server](https://discord.com/invite/GSknuxubZK) to connect with other contributors and get help:
- Chat with the community
- Ask questions
- Share ideas
- Get support

## Report Issues or Suggest Features
Found a bug or have an idea? Let us know!
- Open an issue to report problems
- Open an issue to suggest new features
- Be clear about what you found or what you want

## Make Changes
Want to fix something or add a feature?
- Open a pull request (PR) with your changes
- Look at open issues and try to solve them
- Make sure your code works before submitting

*Note: By submitting a pull request, you agree to the Contributor License Agreement (see below).*

## Getting Started
1. Fork the project
2. Make your changes
3. Test your changes
4. Submit a pull request

## Contributor License Agreement

By submitting code, documentation, or other contributions to this repository, you agree that your contributions are licensed under both:

1. The open source AGPL license included in this repository, and  
2. The commercial license under which this project is also distributed.  

This means the maintainers may use, modify, and distribute your contributions under either license.  
You retain copyright to your contributions, but you grant us a perpetual, worldwide license to include them in both the open source and commercial versions of this project.  

If you do not agree to these terms, please do not submit contributions.



================================================
FILE: docker-compose.yml
================================================
services:
  nginx:
    image: nginx:alpine
    container_name: videoeditor-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro  # Mount certs read-only
    depends_on:
      - frontend
      - backend

  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
      args:
        VITE_SUPABASE_URL: ${VITE_SUPABASE_URL}
        VITE_SUPABASE_ANON_KEY: ${VITE_SUPABASE_ANON_KEY}
    container_name: videoeditor-frontend
    env_file:
      - .env
    environment:
      # Ensure server-side code can construct proper callback URLs
      AUTH_BASE_URL: https://trykimu.com
      AUTH_TRUSTED_ORIGINS: https://trykimu.com,https://www.trykimu.com
      AUTH_COOKIE_DOMAIN: trykimu.com
      NODE_ENV: production
      HOST: 0.0.0.0
      PORT: 3000
    # ports:
    #   - "3000:3000"
    depends_on:
      - backend

  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    container_name: videoeditor-backend
    env_file:
      - .env
    environment:
      AUTH_BASE_URL: https://trykimu.com
      AUTH_TRUSTED_ORIGINS: https://trykimu.com,https://www.trykimu.com
      AUTH_COOKIE_DOMAIN: trykimu.com
      NODE_ENV: production
      PORT: 8000
    # ports:
    #   - "8000:8000"
    volumes:
      - ./out:/app/out
    # Memory configuration for video rendering
    mem_limit: 2g
    memswap_limit: 2g
    shm_size: 1g

  fastapi:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: videoeditor-fastapi


================================================
FILE: Dockerfile.backend
================================================
# Backend Dockerfile

FROM node:22-bookworm-slim
WORKDIR /app

# Install Chrome dependencies
RUN apt-get update
RUN apt install -y \
  libnss3 \
  libdbus-1-3 \
  libatk1.0-0 \
  libgbm-dev \
  libasound2 \
  libxrandr2 \
  libxkbcommon-dev \
  libxfixes3 \
  libxcomposite1 \
  libxdamage1 \
  libatk-bridge2.0-0 \
  libpango-1.0-0 \
  libcairo2 \
  libcups2

# Install pnpm
RUN npm install -g pnpm

# Copy package files and install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Create output directory for rendered videos
RUN mkdir -p /app/out

# Expose port
EXPOSE 8000

# Start the backend
CMD ["pnpm", "dlx", "tsx", "app/videorender/videorender.ts"] 


================================================
FILE: Dockerfile.frontend
================================================
# Frontend Dockerfile

FROM node:20-bookworm-slim
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files and install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Build-time args for Vite env injection
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY

# Expose VITE_* to the build step (and keep at runtime for client hydration if needed)
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL \
    VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY

# Copy source code and build
COPY . .
RUN pnpm run build

# Expose port
EXPOSE 3000

# Start the application
CMD ["pnpm", "run", "start"] 


================================================
FILE: eslint.config.js
================================================
import eslint from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import remotionPlugin from '@remotion/eslint-plugin';

export default [
  eslint.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaFeatures: { jsx: true },
        ecmaVersion: 'latest',
        sourceType: 'module'
      },
      globals: {
        browser: true,
        document: true,
        window: true,
        NodeJS: true,
        JSX: true,
        React: true,
        ReactDOM: true,
      }
    },
    plugins: {
      '@typescript-eslint': tseslint,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
      '@remotion': remotionPlugin
    },
    rules: {
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': 'off',
      'no-unused-vars': 'off',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      'no-console': 'off',
      'no-debugger': 'error',
      'no-duplicate-imports': 'error',
      'no-unused-expressions': 'error',
      'no-var': 'error',
      'prefer-const': 'error',
      'no-undef': 'off',
      'react/jsx-no-undef': 'error',
      'react/no-array-index-key': 'warn',
      'react/no-children-prop': 'error',
      'react/no-danger': 'warn',
      'react/no-deprecated': 'error',
      'react/no-direct-mutation-state': 'error',
      'react/no-find-dom-node': 'error',
      'react/no-is-mounted': 'error',
      'react/no-render-return-value': 'error',
      'react/no-string-refs': 'error',
      'react/no-unknown-property': 'error',
      'react/require-render-return': 'error',
      'react/self-closing-comp': 'error'
    },
    settings: {
      react: {
        version: 'detect'
      }
    }
  },
  {
    files: ['app/video-compositions/*.{ts,tsx}'],
    plugins: {
      '@remotion': remotionPlugin
    },
    rules: remotionPlugin.configs.recommended.rules
  }
]; 


================================================
FILE: LICENSE-AGPL3.md
================================================
GNU Affero General Public License
=================================

_Version 3, 19 November 2007_
_Copyright © 2007 Free Software Foundation, Inc. &lt;<http://fsf.org/>&gt;_

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

## Preamble

The GNU Affero General Public License is a free, copyleft license for
software and other kinds of works, specifically designed to ensure
cooperation with the community in the case of network server software.

The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
our General Public Licenses are intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.

When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

Developers that use our General Public Licenses protect your rights
with two steps: **(1)** assert copyright on the software, and **(2)** offer
you this License which gives you legal permission to copy, distribute
and/or modify the software.

A secondary benefit of defending all users' freedom is that
improvements made in alternate versions of the program, if they
receive widespread use, become available for other developers to
incorporate.  Many developers of free software are heartened and
encouraged by the resulting cooperation.  However, in the case of
software used on network servers, this result may fail to come about.
The GNU General Public License permits making a modified version and
letting the public access it on a server without ever releasing its
source code to the public.

The GNU Affero General Public License is designed specifically to
ensure that, in such cases, the modified source code becomes available
to the community.  It requires the operator of a network server to
provide the source code of the modified version running there to the
users of that server.  Therefore, public use of a modified version, on
a publicly accessible server, gives the public access to the source
code of the modified version.

An older license, called the Affero General Public License and
published by Affero, was designed to accomplish similar goals.  This is
a different license, not a version of the Affero GPL, but Affero has
released a new version of the Affero GPL which permits relicensing under
this license.

The precise terms and conditions for copying, distribution and
modification follow.

## TERMS AND CONDITIONS

### 0. Definitions

“This License” refers to version 3 of the GNU Affero General Public License.

“Copyright” also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

“The Program” refers to any copyrightable work licensed under this
License.  Each licensee is addressed as “you”.  “Licensees” and
“recipients” may be individuals or organizations.

To “modify” a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a “modified version” of the
earlier work or a work “based on” the earlier work.

A “covered work” means either the unmodified Program or a work based
on the Program.

To “propagate” a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

To “convey” a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

An interactive user interface displays “Appropriate Legal Notices”
to the extent that it includes a convenient and prominently visible
feature that **(1)** displays an appropriate copyright notice, and **(2)**
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

### 1. Source Code

The “source code” for a work means the preferred form of the work
for making modifications to it.  “Object code” means any non-source
form of a work.

A “Standard Interface” means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

The “System Libraries” of an executable work include anything, other
than the work as a whole, that **(a)** is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and **(b)** serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
“Major Component”, in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

The “Corresponding Source” for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

The Corresponding Source for a work in source code form is that
same work.

### 2. Basic Permissions

All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

### 3. Protecting Users' Legal Rights From Anti-Circumvention Law

No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

### 4. Conveying Verbatim Copies

You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

### 5. Conveying Modified Source Versions

You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

* **a)** The work must carry prominent notices stating that you modified
it, and giving a relevant date.
* **b)** The work must carry prominent notices stating that it is
released under this License and any conditions added under section 7.
This requirement modifies the requirement in section 4 to
“keep intact all notices”.
* **c)** You must license the entire work, as a whole, under this
License to anyone who comes into possession of a copy.  This
License will therefore apply, along with any applicable section 7
additional terms, to the whole of the work, and all its parts,
regardless of how they are packaged.  This License gives no
permission to license the work in any other way, but it does not
invalidate such permission if you have separately received it.
* **d)** If the work has interactive user interfaces, each must display
Appropriate Legal Notices; however, if the Program has interactive
interfaces that do not display Appropriate Legal Notices, your
work need not make them do so.

A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
“aggregate” if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

### 6. Conveying Non-Source Forms

You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

* **a)** Convey the object code in, or embodied in, a physical product
(including a physical distribution medium), accompanied by the
Corresponding Source fixed on a durable physical medium
customarily used for software interchange.
* **b)** Convey the object code in, or embodied in, a physical product
(including a physical distribution medium), accompanied by a
written offer, valid for at least three years and valid for as
long as you offer spare parts or customer support for that product
model, to give anyone who possesses the object code either **(1)** a
copy of the Corresponding Source for all the software in the
product that is covered by this License, on a durable physical
medium customarily used for software interchange, for a price no
more than your reasonable cost of physically performing this
conveying of source, or **(2)** access to copy the
Corresponding Source from a network server at no charge.
* **c)** Convey individual copies of the object code with a copy of the
written offer to provide the Corresponding Source.  This
alternative is allowed only occasionally and noncommercially, and
only if you received the object code with such an offer, in accord
with subsection 6b.
* **d)** Convey the object code by offering access from a designated
place (gratis or for a charge), and offer equivalent access to the
Corresponding Source in the same way through the same place at no
further charge.  You need not require recipients to copy the
Corresponding Source along with the object code.  If the place to
copy the object code is a network server, the Corresponding Source
may be on a different server (operated by you or a third party)
that supports equivalent copying facilities, provided you maintain
clear directions next to the object code saying where to find the
Corresponding Source.  Regardless of what server hosts the
Corresponding Source, you remain obligated to ensure that it is
available for as long as needed to satisfy these requirements.
* **e)** Convey the object code using peer-to-peer transmission, provided
you inform other peers where the object code and Corresponding
Source of the work are being offered to the general public at no
charge under subsection 6d.

A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

A “User Product” is either **(1)** a “consumer product”, which means any
tangible personal property which is normally used for personal, family,
or household purposes, or **(2)** anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, “normally used” refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

“Installation Information” for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

### 7. Additional Terms

“Additional permissions” are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

* **a)** Disclaiming warranty or limiting liability differently from the
terms of sections 15 and 16 of this License; or
* **b)** Requiring preservation of specified reasonable legal notices or
author attributions in that material or in the Appropriate Legal
Notices displayed by works containing it; or
* **c)** Prohibiting misrepresentation of the origin of that material, or
requiring that modified versions of such material be marked in
reasonable ways as different from the original version; or
* **d)** Limiting the use for publicity purposes of names of licensors or
authors of the material; or
* **e)** Declining to grant rights under trademark law for use of some
trade names, trademarks, or service marks; or
* **f)** Requiring indemnification of licensors and authors of that
material by anyone who conveys the material (or modified versions of
it) with contractual assumptions of liability to the recipient, for
any liability that these contractual assumptions directly impose on
those licensors and authors.

All other non-permissive additional terms are considered “further
restrictions” within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

### 8. Termination

You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated **(a)**
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and **(b)** permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

### 9. Acceptance Not Required for Having Copies

You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

### 10. Automatic Licensing of Downstream Recipients

Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

An “entity transaction” is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

### 11. Patents

A “contributor” is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's “contributor version”.

A contributor's “essential patent claims” are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, “control” includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

In the following three paragraphs, a “patent license” is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To “grant” such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either **(1)** cause the Corresponding Source to be so
available, or **(2)** arrange to deprive yourself of the benefit of the
patent license for this particular work, or **(3)** arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  “Knowingly relying” means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

A patent license is “discriminatory” if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license **(a)** in connection with copies of the covered work
conveyed by you (or copies made from those copies), or **(b)** primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

### 12. No Surrender of Others' Freedom

If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

### 13. Remote Network Interaction; Use with the GNU General Public License

Notwithstanding any other provision of this License, if you modify the
Program, your modified version must prominently offer all users
interacting with it remotely through a computer network (if your version
supports such interaction) an opportunity to receive the Corresponding
Source of your version by providing access to the Corresponding Source
from a network server at no charge, through some standard or customary
means of facilitating copying of software.  This Corresponding Source
shall include the Corresponding Source for any work covered by version 3
of the GNU General Public License that is incorporated pursuant to the
following paragraph.

Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the work with which it is combined will remain governed by version
3 of the GNU General Public License.

### 14. Revised Versions of this License

The Free Software Foundation may publish revised and/or new versions of
the GNU Affero General Public License from time to time.  Such new versions
will be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU Affero General
Public License “or any later version” applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU Affero General Public License, you may choose any version ever published
by the Free Software Foundation.

If the Program specifies that a proxy can decide which future
versions of the GNU Affero General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

### 15. Disclaimer of Warranty

THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM “AS IS” WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

### 16. Limitation of Liability

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

### 17. Interpretation of Sections 15 and 16

If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

_END OF TERMS AND CONDITIONS_

## How to Apply These Terms to Your New Programs

If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the “copyright” line and a pointer to where the full notice is found.

    Open-Source Video Editor
    Copyright (C) 2025 Kimu Team

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

If your software can interact with users remotely through a computer
network, you should also make sure that it provides a way for users to
get its source.  For example, if your program is a web application, its
interface could display a “Source” link that leads users to an archive
of the code.  There are many ways you could offer source, and different
solutions will be better for different programs; see section 13 for the
specific requirements.

You should also get your employer (if you work as a programmer) or school,
if any, to sign a “copyright disclaimer” for the program, if necessary.
For more information on this, and how to apply and follow the GNU AGPL, see
&lt;<http://www.gnu.org/licenses/>&gt;.



================================================
FILE: LICENSE.md
================================================
# License

This project is licensed under a **dual license**:

- **Open Source License**: GNU AGPL v3 (see [LICENSE-AGPL3](LICENSE-AGPL3.md)).  
  Unless you have a separate commercial license from the copyright holder, the AGPL v3 applies by default.  
  Network use (SaaS) triggers the obligation to provide the corresponding source to users interacting with the software over a network.

- **Commercial License**:  
  For closed-source or commercial use without AGPL obligations, you must obtain a commercial license from the copyright holder.  
  Contact: robinroy.work@gmail.com or sr33ch4@yahoo.com

Copyright (c) 2025 Kimu Team


================================================
FILE: nginx.conf
================================================
events {
    worker_connections 1024;
}

http {
    client_max_body_size 500M;

    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:8000;
    }

    upstream fastapi {
        server fastapi:3000;
    }

    # Redirect HTTP → HTTPS
    server {
        listen 80;
        server_name trykimu.com www.trykimu.com;
        return 301 https://$host$request_uri;
    }

    # HTTPS server with TLS + HSTS
    server {
        listen 443 ssl;
        server_name trykimu.com www.trykimu.com;

        ssl_certificate /etc/letsencrypt/live/trykimu.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/trykimu.com/privkey.pem;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

        # trykimu.com/ai/api/ai → http://fastapi/ai
        location /ai/api/ {
            rewrite ^/ai/api/(.*)$ /$1 break;
            proxy_pass http://fastapi;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 900s;
            proxy_send_timeout 900s;
            proxy_request_buffering off;
        }

        # trykimu.com/render/render → http://backend/render
        location /render/ {
            rewrite ^/render/(.*)$ /$1 break;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 900s;
            proxy_send_timeout 900s;
            proxy_request_buffering off;
        }

        # trykimu.com/learn → http://frontend/learn
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}



================================================
FILE: package.json
================================================
{
  "name": "videoeditor",
  "private": true,
  "type": "module",
  "license": "SEE LICENSE IN LICENSE.md",
  "scripts": {
    "build": "react-router build",
    "dev": "react-router dev",
    "start": "react-router-serve ./build/server/index.js",
    "migrate": "tsx app/lib/migrate.ts",
    "typecheck": "react-router typegen && tsc",
    "lint": "eslint . --ext .ts,.tsx",
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  },
  "dependencies": {
    "@radix-ui/react-alert-dialog": "^1.1.15",
    "@radix-ui/react-dialog": "^1.1.15",
    "@radix-ui/react-dropdown-menu": "^2.1.15",
    "@radix-ui/react-label": "^2.1.7",
    "@radix-ui/react-menubar": "^1.1.15",
    "@radix-ui/react-progress": "^1.1.7",
    "@radix-ui/react-scroll-area": "^1.2.9",
    "@radix-ui/react-select": "^2.2.6",
    "@radix-ui/react-separator": "^1.1.7",
    "@radix-ui/react-slot": "^1.2.3",
    "@radix-ui/react-switch": "^1.2.5",
    "@radix-ui/react-tabs": "^1.1.12",
    "@radix-ui/react-tooltip": "^1.2.7",
    "@react-router/node": "^7.7.1",
    "@react-router/serve": "^7.7.1",
    "@remotion/bundler": "4.0.329",
    "@remotion/captions": "4.0.331",
    "@remotion/cli": "4.0.329",
    "@remotion/eslint-plugin": "^4.0.329",
    "@remotion/media-parser": "4.0.329",
    "@remotion/player": "4.0.329",
    "@remotion/renderer": "4.0.329",
    "@remotion/transitions": "4.0.329",
    "@types/cors": "^2.8.19",
    "axios": "^1.12.0",
    "better-auth": "^1.3.7",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "cors": "^2.8.5",
    "dotenv": "^17.2.1",
    "express": "^5.1.0",
    "framer-motion": "^12.23.12",
    "isbot": "^5.1.29",
    "lucide-react": "^0.534.0",
    "motion": "^12.23.12",
    "next-themes": "^0.4.6",
    "pg": "^8.12.0",
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "react-icons": "^5.3.0",
    "react-resizable-panels": "^3.0.4",
    "react-router": "^7.7.1",
    "remotion": "4.0.329",
    "sonner": "^2.0.6",
    "tailwind-merge": "^3.3.1",
    "vaul": "^1.1.2",
    "zod": "4.0.9"
  },
  "pnpm": {
    "overrides": {
      "zod": "4.0.9"
    }
  },
  "devDependencies": {
    "@eslint/js": "^9.32.0",
    "@react-router/dev": "^7.7.1",
    "@tailwindcss/vite": "^4.1.11",
    "@types/express": "^5.0.3",
    "@types/multer": "^2.0.0",
    "@types/node": "^24.1.0",
    "@types/pg": "^8.15.5",
    "@types/react": "^19.1.9",
    "@types/react-dom": "^19.1.7",
    "@typescript-eslint/eslint-plugin": "^8.38.0",
    "@typescript-eslint/parser": "^8.38.0",
    "eslint": "^9.32.0",
    "eslint-plugin-react": "^7.37.5",
    "eslint-plugin-react-hooks": "^5.2.0",
    "multer": "^2.0.2",
    "prettier": "^3.3.3",
    "tailwindcss": "^4.1.11",
    "ts-node": "^10.9.2",
    "tsx": "^4.20.4",
    "tw-animate-css": "^1.3.6",
    "typescript": "^5.8.3",
    "vite": "^7.0.7",
    "vite-tsconfig-paths": "^5.1.4"
  }
}



================================================
FILE: react-router.config.ts
================================================
import type { Config } from "@react-router/dev/config";

export default {
  // Config options...
  // Server-side render by default, to enable SPA mode set this to `false`
  ssr: true,
} satisfies Config;



================================================
FILE: SECURITY.md
================================================
## Security Updates

We take security seriously. Security updates are released as soon as possible after a vulnerability is discovered and verified.

## Reporting a Vulnerability

If you discover a security vulnerability, please follow these steps:

1. **DO NOT** disclose the vulnerability publicly.
2. Send a detailed report to: `robinroy.work@gmail.com`.
3. Include in your report:
   - A description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact


================================================
FILE: tsconfig.json
================================================
{
  "include": [
    "**/*",
    "**/.server/**/*",
    "**/.client/**/*",
    ".react-router/types/**/*"
  ],
  "compilerOptions": {
    "lib": ["DOM", "DOM.Iterable", "ES2022"],
    "types": ["node"],
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "rootDirs": [".", "./.react-router/types"],
    "baseUrl": ".",
    "paths": {
      "~/*": ["./app/*"]
    },
    "esModuleInterop": true,
    "verbatimModuleSyntax": true,
    "noEmit": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "strict": true
  }
}



================================================
FILE: vite.config.ts
================================================
import { reactRouter } from "@react-router/dev/vite";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tailwindcss(), reactRouter(), tsconfigPaths()],
});



================================================
FILE: .dockerignore
================================================
node_modules
build
.react-router
out
*.log
.env
.git
.gitignore
README.md
docker-compose.yml
Dockerfile*


================================================
FILE: .env.example
================================================
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
DATABASE_URL=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=


================================================
FILE: .prettierignore
================================================

node_modules
build
out
dist

# lockfiles
pnpm-lock.yaml
yarn.lock
package-lock.json

# generated types
app/routes/**/+types*

coverage
*.log
.DS_Store
.env*
**/*.min.*





================================================
FILE: .prettierrc
================================================
{
  "printWidth": 120,
  "bracketSameLine": true,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": false,
  "trailingComma": "all",
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf"
}



================================================
FILE: app/app.css
================================================
@import "tailwindcss";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme {
  --font-sans: "Inter", ui-sans-serif, system-ui, sans-serif,
    "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
}

html,
body {
  /* Background now derives strictly from theme tokens via body classes */
}

@theme inline {
  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
  --color-background: rgb(var(--background));
  --color-foreground: rgb(var(--foreground));
  --color-card: rgb(var(--card));
  --color-card-foreground: rgb(var(--card-foreground));
  --color-popover: rgb(var(--popover));
  --color-popover-foreground: rgb(var(--popover-foreground));
  --color-primary: rgb(var(--primary));
  --color-primary-foreground: rgb(var(--primary-foreground));
  --color-secondary: rgb(var(--secondary));
  --color-secondary-foreground: rgb(var(--secondary-foreground));
  --color-muted: rgb(var(--muted));
  --color-muted-foreground: rgb(var(--muted-foreground));
  --color-accent: rgb(var(--accent));
  --color-accent-foreground: rgb(var(--accent-foreground));
  --color-destructive: rgb(var(--destructive));
  --color-destructive-foreground: rgb(var(--destructive-foreground));
  --color-border: rgb(var(--border));
  --color-input: rgb(var(--input));
  --color-ring: rgb(var(--ring));
  --color-chart-1: rgb(var(--chart-1));
  --color-chart-2: rgb(var(--chart-2));
  --color-chart-3: rgb(var(--chart-3));
  --color-chart-4: rgb(var(--chart-4));
  --color-chart-5: rgb(var(--chart-5));

  /* Video editor specific colors */
  --color-panel-background: rgb(var(--panel-background));
  --color-panel-border: rgb(var(--panel-border));
  --color-panel-header: rgb(var(--panel-header));
  --color-timeline-background: rgb(var(--timeline-background));
  --color-timeline-track: rgb(var(--timeline-track));
  --color-timeline-ruler: rgb(var(--timeline-ruler));
  --color-scrubber: rgb(var(--scrubber));
  --color-playhead: rgb(var(--playhead));
}

:root {
  --radius: 0.375rem;

  /* Light theme - Clean monochrome with blue accent */
  --background: 255 255 255;
  --foreground: 15 23 42;
  --card: 255 255 255;
  --card-foreground: 15 23 42;
  --popover: 255 255 255;
  --popover-foreground: 15 23 42;
  --primary: 37 99 235; /* Clean blue accent */
  --primary-foreground: 255 255 255;
  --secondary: 248 250 252;
  --secondary-foreground: 51 65 85;
  --muted: 241 245 249;
  --muted-foreground: 100 116 139;
  --accent: 241 245 249;
  --accent-foreground: 51 65 85;
  --destructive: 220 38 38;
  --destructive-foreground: 255 255 255;
  --border: 226 232 240;
  --input: 226 232 240;
  --ring: 37 99 235;
  --chart-1: 37 99 235;
  --chart-2: 34 197 94;
  --chart-3: 168 85 247;
  --chart-4: 251 146 60;
  --chart-5: 220 38 38;

  /* Panel colors */
  --panel-background: 248 250 252;
  --panel-border: 226 232 240;
  --panel-header: 241 245 249;

  /* Video editor specific */
  --timeline-background: 248 250 252;
  --timeline-track: 255 255 255;
  --timeline-ruler: 241 245 249;
  --scrubber: 37 99 235;
  --playhead: 220 38 38;
}

.dark {
  --background: 9 9 11;
  --foreground: 255 255 255;
  --card: 18 18 20;
  --card-foreground: 255 255 255;
  --popover: 18 18 20;
  --popover-foreground: 255 255 255;
  --primary: 198 255 0; /* Neon yellow-green accent for dark mode */
  --primary-foreground: 9 9 11;
  --secondary: 39 39 42;
  --secondary-foreground: 255 255 255;
  --muted: 39 39 42;
  --muted-foreground: 161 161 170;
  --accent: 39 39 42;
  --accent-foreground: 255 255 255;
  --destructive: 239 68 68;
  --destructive-foreground: 255 255 255;
  --border: 39 39 42;
  --input: 39 39 42;
  --ring: 198 255 0;
  --chart-1: 198 255 0;
  --chart-2: 59 130 246;
  --chart-3: 168 85 247;
  --chart-4: 251 146 60;
  --chart-5: 239 68 68;

  /* Panel colors for dark mode */
  --panel-background: 18 18 20;
  --panel-border: 39 39 42;
  --panel-header: 39 39 42;

  /* Video editor specific for dark mode */
  --timeline-background: 9 9 11;
  --timeline-track: 18 18 20;
  --timeline-ruler: 39 39 42;
  --scrubber: 198 255 0;
  --playhead: 239 68 68;
}

@layer base {
  * {
    border-color: rgb(var(--border));
    outline-color: rgb(var(--ring) / 0.5);
  }
  body {
    background-color: rgb(var(--background));
    color: rgb(var(--foreground));
  }

  /* Theme-aware scrollbars */
  ::-webkit-scrollbar {
    width: 12px;
    height: 12px;
  }

  ::-webkit-scrollbar-track {
    background: rgb(var(--muted));
    border-radius: 6px;
  }

  ::-webkit-scrollbar-thumb {
    background: rgb(var(--muted-foreground) / 0.5);
    border-radius: 6px;
    border: 2px solid rgb(var(--muted));
  }

  ::-webkit-scrollbar-thumb:hover {
    background: rgb(var(--muted-foreground) / 0.7);
  }

  ::-webkit-scrollbar-thumb:active {
    background: rgb(var(--muted-foreground) / 0.8);
  }

  ::-webkit-scrollbar-corner {
    background: rgb(var(--muted));
  }

  /* Thinner scrollbars for timeline and panels */
  .timeline-scrollbar::-webkit-scrollbar,
  .panel-scrollbar::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  .timeline-scrollbar::-webkit-scrollbar-thumb,
  .panel-scrollbar::-webkit-scrollbar-thumb {
    border: 1px solid rgb(var(--muted));
  }

  /* Firefox */
  * {
    scrollbar-width: thin;
    scrollbar-color: rgb(var(--muted-foreground) / 0.5) rgb(var(--muted));
  }

  /* Chat specific styles - ensure proper text wrapping */
  .chat-message-content {
    word-wrap: break-word;
    overflow-wrap: break-word;
    word-break: break-word;
    hyphens: auto;
    white-space: pre-wrap;
    max-width: 100%;
  }

  /* Prevent horizontal overflow in chat areas */
  .chat-container * {
    max-width: 100%;
    overflow-x: hidden;
  }

  /* Ensure textarea never exceeds container width */
  .chat-input-area textarea {
    max-width: 100%;
    box-sizing: border-box;
  }
}

/* Custom animations for 404 page */
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(40px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
}

@keyframes float-delayed {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-30px) rotate(-180deg);
  }
}

@keyframes float-slow {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
  }
  50% {
    transform: translateY(-15px) rotate(90deg);
  }
}

@keyframes float-reverse {
  0%,
  100% {
    transform: translateY(-10px) rotate(0deg);
  }
  50% {
    transform: translateY(10px) rotate(180deg);
  }
}

@keyframes float-gentle {
  0%,
  100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-8px);
  }
}

@keyframes twinkle {
  0%,
  100% {
    opacity: 0.3;
    transform: scale(1);
  }
  50% {
    opacity: 1;
    transform: scale(1.2);
  }
}

@keyframes pulse-slow {
  0%,
  100% {
    opacity: 0.8;
  }
  50% {
    opacity: 0.3;
  }
}

@keyframes spin-slow {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* Enhanced animations for polished 404 page */
@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

@keyframes glow-pulse {
  0%,
  100% {
    box-shadow: 0 0 20px rgba(37, 99, 235, 0.1),
      0 0 40px rgba(37, 99, 235, 0.05);
  }
  50% {
    box-shadow: 0 0 30px rgba(37, 99, 235, 0.2), 0 0 60px rgba(37, 99, 235, 0.1);
  }
}

@keyframes float-icon {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
  }
  25% {
    transform: translateY(-8px) rotate(2deg);
  }
  50% {
    transform: translateY(-4px) rotate(0deg);
  }
  75% {
    transform: translateY(-12px) rotate(-2deg);
  }
}

@keyframes gradient-shift {
  0%,
  100% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
}

@keyframes border-glow {
  0%,
  100% {
    border-color: rgba(37, 99, 235, 0.2);
    box-shadow: 0 0 0 1px rgba(37, 99, 235, 0.1);
  }
  50% {
    border-color: rgba(37, 99, 235, 0.4);
    box-shadow: 0 0 0 1px rgba(37, 99, 235, 0.2);
  }
}

.animate-fade-in {
  animation: fade-in 0.8s ease-out;
}

.animate-fade-in-up {
  animation: fade-in-up 1s ease-out;
}

.animate-float {
  animation: float 6s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 8s ease-in-out infinite;
  animation-delay: 2s;
}

.animate-float-slow {
  animation: float-slow 10s ease-in-out infinite;
  animation-delay: 1s;
}

.animate-float-reverse {
  animation: float-reverse 7s ease-in-out infinite;
  animation-delay: 3s;
}

.animate-float-gentle {
  animation: float-gentle 4s ease-in-out infinite;
}

.animate-twinkle {
  animation: twinkle 2s ease-in-out infinite;
}

.animate-pulse-slow {
  animation: pulse-slow 3s ease-in-out infinite;
}

.animate-spin-slow {
  animation: spin-slow 3s linear infinite;
}

.animate-shimmer {
  animation: shimmer 3s ease-in-out infinite;
}

.animate-glow-pulse {
  animation: glow-pulse 4s ease-in-out infinite;
}

.animate-float-icon {
  animation: float-icon 6s ease-in-out infinite;
}

.animate-gradient-shift {
  animation: gradient-shift 8s ease-in-out infinite;
  background-size: 200% 200%;
}

.animate-border-glow {
  animation: border-glow 3s ease-in-out infinite;
}

/* Glass morphism effects */
.glass-morphism {
  backdrop-filter: blur(16px) saturate(180%);
  background-color: rgba(255, 255, 255, 0.75);
  border: 1px solid rgba(255, 255, 255, 0.125);
}

.glass-morphism-dark {
  backdrop-filter: blur(16px) saturate(180%);
  background-color: rgba(17, 25, 40, 0.75);
  border: 1px solid rgba(255, 255, 255, 0.125);
}

/* Enhanced shadow utilities */
.shadow-3xl {
  box-shadow: 0 35px 60px -12px rgba(0, 0, 0, 0.25);
}

.shadow-glow {
  box-shadow: 0 0 20px rgba(37, 99, 235, 0.15);
}

.shadow-glow-lg {
  box-shadow: 0 0 40px rgba(37, 99, 235, 0.2);
}

/* Indeterminate top loader */
.indeterminate-line {
  position: relative;
  height: 2px;
  width: 100%;
  overflow: hidden;
  background: transparent;
}
.indeterminate-line::before {
  content: "";
  position: absolute;
  left: -40%;
  top: 0;
  height: 100%;
  width: 40%;
  background: currentColor;
  border-radius: 2px;
  animation: indeterminate-slide 1.2s ease-in-out infinite;
}

@keyframes indeterminate-slide {
  0% { left: -40%; width: 40%; }
  50% { left: 20%; width: 60%; }
  100% { left: 100%; width: 40%; }
}


================================================
FILE: app/NotFound.tsx
================================================
import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Button } from "./components/ui/button";
import {
  ArrowRight,
  MessageCircle,
  Play,
  SkipBack,
  SkipForward,
  Volume2,
  Clapperboard,
  Scissors,
  Image,
  Video,
  Music,
  Sparkles,
  Stars,
} from "lucide-react";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { GlowingEffect } from "~/components/ui/glowing-effect";
import { useNavigate } from "react-router";

const MEDIA_KEYS = Array.from({ length: 10 }, (_, i) => `media-item-${i}`);
const TIMELINE_KEYS = Array.from({ length: 15 }, (_, i) => `timeline-mark-${i}`);
const TOOL_KEYS = Array.from({ length: 12 }, (_, i) => `tool-${i}`);
const TYPING_KEYS = Array.from({ length: 3 }, (_, i) => `typing-dot-${i}`);

export default function NotFound(): React.ReactElement {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(0);
  const [isTyping, setIsTyping] = useState(false);

  useEffect(() => {
    const timer1 = setTimeout(() => {
      setCurrentStep(1);
    }, 800);

    const timer2 = setTimeout(() => {
      setIsTyping(true);
    }, 2500);

    const timer3 = setTimeout(() => {
      setIsTyping(false);
      setCurrentStep(2);
    }, 4000);

    const timer4 = setTimeout(() => {
      setCurrentStep(3);
    }, 4500);

    return () => {
      clearTimeout(timer1);
      clearTimeout(timer2);
      clearTimeout(timer3);
      clearTimeout(timer4);
    };
  }, []);

  const handleGoHome = () => {
    navigate("/");
  };

  return (
    <div className="min-h-screen bg-background text-foreground flex items-center justify-center p-6 relative overflow-hidden">
      {/* Video Editor Background Interface - Animated Opacity Waves */}
      <div className="absolute inset-0 pointer-events-none">
        {/* Top Menu Bar - Wave 1 */}
        <motion.div
          className="absolute top-0 left-0 right-0 h-12 border-b border-border/30 bg-muted/10"
          animate={{
            opacity: [0.08, 0.12, 0.08],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        >
          <div className="flex items-center h-full px-4 gap-6">
            <div className="w-20 h-7 bg-muted-foreground/40 rounded" />
            <div className="w-16 h-7 bg-muted-foreground/40 rounded" />
            <div className="w-18 h-7 bg-muted-foreground/40 rounded" />
            <div className="w-14 h-7 bg-muted-foreground/40 rounded" />
          </div>
        </motion.div>

        {/* Left Panel - Media Bin - Wave 2 */}
        <motion.div
          className="absolute top-12 left-0 w-72 bottom-48 border-r border-border/30 bg-muted/10"
          animate={{
            opacity: [0.06, 0.1, 0.06],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 2,
          }}
        >
          <div className="h-10 border-b-2 border-muted-foreground/30 bg-muted/25 flex items-center px-4">
            <div className="w-20 h-5 bg-muted-foreground/40 rounded" />
          </div>
          <div className="p-4 space-y-3">
            {MEDIA_KEYS.map((key, i) => (
              <div key={key} className="flex items-center gap-3">
                {i % 3 === 0 ? (
                  <Video className="w-5 h-5 text-muted-foreground/60" />
                ) : i % 3 === 1 ? (
                  <Image className="w-5 h-5 text-muted-foreground/60" />
                ) : (
                  <Music className="w-5 h-5 text-muted-foreground/60" />
                )}
                <div className="w-24 h-4 bg-muted-foreground/40 rounded" />
                <div className="w-12 h-3 bg-muted-foreground/30 rounded text-xs" />
              </div>
            ))}
          </div>
        </motion.div>

        {/* Right Panel - Preview - Wave 3 */}
        <motion.div
          className="absolute top-12 right-0 w-96 h-80 border-l border-b border-border/30 bg-muted/10"
          animate={{
            opacity: [0.05, 0.09, 0.05],
          }}
          transition={{
            duration: 12,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 4,
          }}
        >
          <div className="h-10 border-b-2 border-muted-foreground/30 bg-muted/25 flex items-center px-4">
            <div className="w-16 h-5 bg-muted-foreground/40 rounded" />
          </div>
          <div className="p-6">
            <div className="w-full h-48 border border-border/30 rounded-lg bg-muted/10 flex items-center justify-center">
              <motion.div
                animate={{
                  scale: [1, 1.05, 1],
                  opacity: [0.6, 0.8, 0.6],
                }}
                transition={{
                  duration: 6,
                  repeat: Infinity,
                  ease: "easeInOut",
                }}
              >
                <Play className="w-12 h-12 text-muted-foreground/60" />
              </motion.div>
            </div>
            <div className="flex justify-center gap-4 mt-4">
              <SkipBack className="w-6 h-6 text-muted-foreground/60" />
              <Play className="w-8 h-8 text-muted-foreground/60" />
              <SkipForward className="w-6 h-6 text-muted-foreground/60" />
              <Volume2 className="w-6 h-6 text-muted-foreground/60 ml-4" />
            </div>
          </div>
        </motion.div>

        {/* Bottom Timeline - Wave 4 */}
        <motion.div
          className="absolute bottom-0 left-0 right-0 h-48 border-t border-border/30 bg-muted/10"
          animate={{
            opacity: [0.07, 0.11, 0.07],
          }}
          transition={{
            duration: 9,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 1,
          }}
        >
          {/* Timeline ruler */}
          <div className="h-8 border-b-2 border-muted-foreground/30 bg-muted/25 flex items-center px-6">
            {TIMELINE_KEYS.map((key, i) => (
              <div
                key={key}
                className="flex-1 text-sm text-muted-foreground/60 border-l border-muted-foreground/30 pl-2"
              >
                {i * 10}s
              </div>
            ))}
          </div>

          {/* Timeline tracks */}
          <div className="flex-1 space-y-1 p-2">
            {/* Video track */}
            <motion.div
              className="h-10 border border-border/30 bg-muted/10 rounded flex items-center px-4"
              animate={{
                opacity: [1, 0.7, 1],
              }}
              transition={{
                duration: 4,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 0.5,
              }}
            >
              <Video className="w-5 h-5 mr-3 text-muted-foreground/60" />
              <div className="flex gap-2">
                <div className="w-20 h-6 bg-blue-500/50 rounded" />
                <div className="w-16 h-6 bg-blue-500/50 rounded" />
                <div className="w-24 h-6 bg-blue-500/50 rounded" />
                <div className="w-12 h-6 bg-blue-500/50 rounded" />
              </div>
            </motion.div>

            {/* Audio track */}
            <motion.div
              className="h-10 border border-border/30 bg-muted/10 rounded flex items-center px-4"
              animate={{
                opacity: [1, 0.6, 1],
              }}
              transition={{
                duration: 5,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 1.5,
              }}
            >
              <Music className="w-5 h-5 mr-3 text-muted-foreground/60" />
              <div className="flex gap-2">
                <div className="w-32 h-6 bg-green-500/50 rounded" />
                <div className="w-20 h-6 bg-green-500/50 rounded" />
                <div className="w-16 h-6 bg-green-500/50 rounded" />
              </div>
            </motion.div>

            {/* Effects track */}
            <motion.div
              className="h-10 border border-border/30 bg-muted/10 rounded flex items-center px-4"
              animate={{
                opacity: [1, 0.8, 1],
              }}
              transition={{
                duration: 6,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 2.5,
              }}
            >
              <Scissors className="w-5 h-5 mr-3 text-muted-foreground/60" />
              <div className="flex gap-2">
                <div className="w-12 h-6 bg-purple-500/50 rounded" />
                <div className="w-8 h-6 bg-purple-500/50 rounded" />
                <div className="w-14 h-6 bg-purple-500/50 rounded" />
                <div className="w-10 h-6 bg-purple-500/50 rounded" />
              </div>
            </motion.div>
          </div>

          {/* Playhead - Animated */}
          <motion.div
            className="absolute top-8 left-40 w-1 h-32 bg-red-500/70 rounded"
            animate={{
              opacity: [0.7, 1, 0.7],
              scaleY: [1, 1.05, 1],
            }}
            transition={{
              duration: 3,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
        </motion.div>

        {/* Tools Panel - Wave 5 */}
        <motion.div
          className="absolute top-96 right-0 w-96 h-40 border-l border-t border-border/30 bg-muted/10"
          animate={{
            opacity: [0.04, 0.08, 0.04],
          }}
          transition={{
            duration: 11,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 3,
          }}
        >
          <div className="h-10 border-b-2 border-muted-foreground/30 bg-muted/25 flex items-center px-4">
            <div className="w-20 h-5 bg-muted-foreground/40 rounded" />
          </div>
          <div className="p-4 grid grid-cols-6 gap-3">
            {TOOL_KEYS.map((key, i) => (
              <motion.div
                key={key}
                className="w-full h-10 border border-muted-foreground/30 rounded bg-muted/20"
                animate={{
                  opacity: [1, 0.5, 1],
                }}
                transition={{
                  duration: 7,
                  repeat: Infinity,
                  ease: "easeInOut",
                  delay: i * 0.3,
                }}
              />
            ))}
          </div>
        </motion.div>
      </div>

      {/* Enhanced floating elements for playful touch */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {/* Floating video icons */}
        <motion.div
          className="absolute top-20 left-20"
          animate={{
            y: [0, -15, 0],
            rotate: [0, 5, -5, 0],
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
        >
          <Video className="w-6 h-6 text-primary/20" />
        </motion.div>

        <motion.div
          className="absolute top-40 right-32"
          animate={{
            y: [0, 12, 0],
            rotate: [0, -3, 3, 0],
            opacity: [0.15, 0.35, 0.15],
          }}
          transition={{
            duration: 7,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 1.5,
          }}
        >
          <Music className="w-5 h-5 text-accent/25" />
        </motion.div>

        <motion.div
          className="absolute bottom-32 left-1/3"
          animate={{
            y: [0, -10, 0],
            rotate: [0, 8, -8, 0],
            opacity: [0.25, 0.45, 0.25],
          }}
          transition={{
            duration: 5,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 3,
          }}
        >
          <Scissors className="w-4 h-4 text-purple-400/30" />
        </motion.div>

        <motion.div
          className="absolute top-1/3 left-16"
          animate={{
            y: [0, 18, 0],
            rotate: [0, -6, 6, 0],
            opacity: [0.1, 0.3, 0.1],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 2,
          }}
        >
          <Image className="w-5 h-5 text-blue-400/25" />
        </motion.div>

        <motion.div
          className="absolute bottom-40 right-20"
          animate={{
            y: [0, -12, 0],
            rotate: [0, 4, -4, 0],
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{
            duration: 6.5,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 4,
          }}
        >
          <Sparkles className="w-4 h-4 text-yellow-400/30" />
        </motion.div>

        <motion.div
          className="absolute top-60 right-1/4"
          animate={{
            y: [0, 8, 0],
            rotate: [0, -2, 2, 0],
            opacity: [0.15, 0.35, 0.15],
          }}
          transition={{
            duration: 9,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 1,
          }}
        >
          <Stars className="w-3 h-3 text-indigo-400/25" />
        </motion.div>

        {/* Subtle gradient orbs for depth */}
        <motion.div
          className="absolute top-16 right-16 w-12 h-12 bg-gradient-to-br from-muted/40 to-transparent rounded-full blur-sm"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div
          className="absolute bottom-20 left-12 w-8 h-8 bg-gradient-to-br from-muted/30 to-transparent rounded-full blur-sm"
          animate={{
            scale: [1, 1.3, 1],
            opacity: [0.2, 0.5, 0.2],
          }}
          transition={{
            duration: 12,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 3,
          }}
        />
      </div>

      <div className="w-full max-w-2xl mx-auto relative z-10 px-4 sm:px-6">
        {/* 404 Display at Top - Enhanced */}
        <motion.div
          className="text-center mb-10"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
        >
          <div className="relative inline-block">
            <div className="flex items-center justify-center gap-2 sm:gap-4 text-6xl sm:text-7xl md:text-8xl font-bold text-muted/70 mb-3">
              <span className="tracking-tight">4</span>
              <motion.div
                animate={{
                  rotateY: [0, 10, -10, 0],
                  scale: [1, 1.05, 1],
                }}
                transition={{
                  duration: 4,
                  repeat: Infinity,
                  ease: "easeInOut",
                }}
              >
                <Clapperboard className="w-16 h-16 sm:w-18 sm:h-18 md:w-20 md:h-20 text-muted/70 mx-1" />
              </motion.div>
              <span className="tracking-tight">4</span>
            </div>
            {/* Subtle glow effect */}
            {/* <div className="absolute inset-0 bg-gradient-to-r from-primary/5 via-primary/10 to-primary/5 rounded-2xl blur-3xl -z-10"></div> */}
          </div>
        </motion.div>

        {/* Discord-style Chat Interface - No Card Background */}
        <div className="relative w-full max-w-lg mx-auto">
          {/* First message with avatar and username */}
          <motion.div
            className="flex items-start gap-3 mb-1"
            initial={{ opacity: 0, y: 10 }}
            animate={{
              opacity: currentStep >= 1 ? 1 : 0,
              y: currentStep >= 1 ? 0 : 10,
            }}
            transition={{ duration: 0.6, ease: "easeOut" }}
          >
            <motion.div
              className="w-8 h-8 bg-muted/20 rounded-full flex items-center justify-center flex-shrink-0 mt-1 border border-border/30 shadow-sm"
              animate={{
                scale: [1, 1.05, 1],
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            >
              <KimuLogo className="w-4 h-4" />
            </motion.div>
            <div className="flex flex-col flex-1 min-w-0">
              <div className="flex items-baseline gap-2 mb-1">
                <span className="text-sm font-semibold text-foreground">
                  Kimu
                </span>
                <div className="w-1.5 h-1.5 bg-green-500 rounded-full" />
              </div>
              <div className="bg-muted/15 rounded-2xl rounded-tl-sm px-4 py-2.5 shadow-sm border border-border/30 w-fit max-w-[280px] sm:max-w-xs relative">
                <div className="absolute -inset-1 rounded-2xl pointer-events-none">
                  <GlowingEffect
                    disabled={false}
                    spread={36}
                    proximity={64}
                    glow
                    borderWidth={2}
                    hoverBorderWidth={4}
                  />
                </div>
                <p className="text-sm text-foreground">Hey there! 👋</p>
                <p className="text-sm text-muted-foreground mt-1">
                  I couldn't find that page for you. It seems to have
                  disappeared into the digital void...
                </p>
              </div>
            </div>
          </motion.div>

          {/* Second message - consecutive message */}
          <div className="flex items-start gap-3 mb-1">
            <div className="w-8 h-8 flex-shrink-0" />
            <div className="flex flex-col flex-1 min-w-0 relative">
              {/* Typing indicator */}
              <motion.div
                className="absolute top-0 left-0"
                initial={{ opacity: 0 }}
                animate={{ opacity: isTyping ? 1 : 0 }}
                transition={{ duration: 0.3 }}
              >
                <div className="bg-muted/20 rounded-2xl px-4 py-3 shadow-sm border border-border/30 w-fit">
                  <div className="flex items-center gap-2">
                    <div className="flex space-x-1">
                      {TYPING_KEYS.map((key, i) => (
                        <motion.div
                          key={key}
                          className="w-2 h-2 bg-muted-foreground/60 rounded-full"
                          animate={{
                            scale: [1, 1.4, 1],
                            opacity: [0.5, 1, 0.5],
                          }}
                          transition={{
                            duration: 0.8,
                            repeat: Infinity,
                            delay: i * 0.15,
                          }}
                        />
                      ))}
                    </div>
                    {/* <span className="text-xs text-muted-foreground italic">
                      typing...
                    </span> */}
                  </div>
                </div>
              </motion.div>

              {/* Actual second message */}
              <motion.div
                className="relative"
                initial={{ opacity: 0, y: 5 }}
                animate={{
                  opacity: currentStep >= 2 && !isTyping ? 1 : 0,
                  y: currentStep >= 2 && !isTyping ? 0 : 5,
                }}
                transition={{ duration: 0.6, ease: "easeOut", delay: 0.2 }}
              >
                <div className="bg-muted/15 rounded-2xl px-4 py-2.5 shadow-sm border border-border/30 w-fit max-w-[300px] sm:max-w-sm relative">
                  <div className="absolute -inset-1 rounded-2xl pointer-events-none">
                    <GlowingEffect
                      disabled={false}
                      spread={28}
                      proximity={48}
                      glow
                      borderWidth={2}
                      hoverBorderWidth={4}
                    />
                  </div>
                  <p className="text-sm text-foreground mb-2">
                    But hey! 🎬 Need some{" "}
                    <span className="font-bold">video editing magic</span>?
                  </p>
                  <p className="text-sm text-muted-foreground mb-2">
                    I'm your AI-powered creative partner, ready to transform
                    your raw footage into{" "}
                    <span className="font-semibold text-foreground">
                      cinematic masterpieces
                    </span>
                    ! ✨
                  </p>
                  <p className="text-sm font-bold">
                    Let's create something amazing together! 🚀
                  </p>
                </div>
              </motion.div>
            </div>
          </div>

          {/* Third message - Button as message */}
          <div className="flex items-start gap-3">
            <div className="w-8 h-8 flex-shrink-0" />
            <div className="flex flex-col flex-1 min-w-0 mt-2">
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{
                  opacity: currentStep >= 3 ? 1 : 0,
                  y: currentStep >= 3 ? 0 : 10,
                }}
                transition={{ duration: 0.6, ease: "easeOut", delay: 0.2 }}
              >
                <Button
                  onClick={handleGoHome}
                  className="bg-foreground text-background hover:bg-foreground/90 transition-all duration-300 shadow-lg hover:shadow-xl border border-transparent rounded-2xl font-semibold text-sm relative overflow-hidden px-4 py-3 h-auto w-fit max-w-[300px] sm:max-w-sm"
                >
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
                    animate={{ x: ["-100%", "100%"] }}
                    transition={{
                      duration: 3,
                      repeat: Infinity,
                      ease: "linear",
                    }}
                  />
                  <div className="flex items-center gap-2 relative z-10">
                    <MessageCircle className="w-4 h-4" />
                    <span>Start Creating with Kimu</span>
                    <ArrowRight className="w-4 h-4" />
                  </div>
                </Button>
              </motion.div>
            </div>
          </div>
        </div>

        {/* Footer - Enhanced */}
        <motion.div
          className="mt-8 text-center"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.2, duration: 0.6 }}
        >
          <div
            className="opacity-0"
            style={{
              opacity: currentStep >= 3 ? 1 : 0,
              transition: "opacity 0.6s ease 1s",
            }}
          >
            <p className="text-xs text-muted-foreground/30 font-medium">
              Ready to bring your vision to life? <br /> Let's dive into the
              editor!
            </p>
          </div>
        </motion.div>
      </div>
    </div>
  );
}



================================================
FILE: app/root.tsx
================================================
import {
  isRouteErrorResponse,
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  useLoaderData,
  useLocation,
  useMatches,
} from "react-router";
import { useEffect, useState } from "react";

import "./app.css";
import { Toaster } from "./components/ui/sonner";
import { ThemeProvider } from "./components/ui/ThemeProvider";
import { auth } from "~/lib/auth.server";
import { Navbar } from "~/components/ui/Navbar";
import { MarketingFooter } from "~/components/ui/MarketingFooter";
import type { User } from "better-auth";

export const links = () => [
  { rel: "icon", href: "/favicon.png" },
  { rel: "preconnect", href: "https://fonts.googleapis.com" },
  {
    rel: "preconnect",
    href: "https://fonts.gstatic.com",
    crossOrigin: "anonymous",
  },
  {
    rel: "stylesheet",
    href: "https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap",
  },
];

export async function loader({ request }: { request: Request }) {
  try {
    // @ts-ignore
    const session = await auth.api?.getSession?.({ headers: request.headers });
    const user = session?.user || null;
    return { user };
  } catch {
    return { user: null };
  }
}

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
        <script defer src="https://cloud.umami.is/script.js" data-website-id="d8ab00c1-6fa6-4aad-b152-e14e178c0f24" />
      </head>
      <body className="min-h-screen font-sans antialiased">
        <ThemeProvider>
          <main className="min-h-screen w-full overflow-x-hidden">{children}</main>
          <Toaster position="top-right" expand={false} richColors closeButton />
          <ScrollRestoration />
          <Scripts />
        </ThemeProvider>
      </body>
    </html>
  );
}

export default function App() {
  const data = useLoaderData<typeof loader>() as { user: User };
  const location = useLocation();
  const matches = useMatches();
  const [showBrand, setShowBrand] = useState(true);
  const isNotFound = (matches[matches.length - 1]?.id || "").includes("NotFound");
  const hideNavbar =
    isNotFound ||
    location.pathname === "/projects" ||
    location.pathname.startsWith("/project/") ||
    location.pathname === "/profile";
  const hideFooter =
    isNotFound ||
    location.pathname === "/projects" ||
    location.pathname.startsWith("/project/") ||
    location.pathname === "/profile";

  useEffect(() => {
    // Only apply hero intersection logic on the landing page
    if (location.pathname === "/") {
      const hero = document.getElementById("hero-section");
      if (!hero) {
        setShowBrand(true);
        return;
      }
      const observer = new IntersectionObserver(
        (entries) => {
          const e = entries[0];
          setShowBrand(!e.isIntersecting);
        },
        { root: null, threshold: 0.25 },
      );
      observer.observe(hero);
      return () => observer.disconnect();
    } else {
      // On other pages, always show the brand
      setShowBrand(true);
    }
  }, [location.pathname]);

  return (
    <>
      {!hideNavbar && <Navbar showBrand={showBrand} />}
      <Outlet />
      {!hideFooter && <MarketingFooter />}
    </>
  );
}

export function ErrorBoundary({ error }: { error: Error }) {
  let message = "Oops!";
  let details = "An unexpected error occurred.";
  let stack: string | undefined;

  if (isRouteErrorResponse(error)) {
    message = error.status === 404 ? "404" : "Error";
    details = error.status === 404 ? "The requested page could not be found." : error.statusText || details;
  } else if (process.env.NODE_ENV === "development" && error && error instanceof Error) {
    details = error.message;
    stack = error.stack;
  }

  return (
    <main className="pt-16 p-4 container mx-auto">
      <h1>{message}</h1>
      <p>{details}</p>
      {stack && (
        <pre className="w-full p-4 overflow-x-auto">
          <code>{stack}</code>
        </pre>
      )}
    </main>
  );
}



================================================
FILE: app/routes.ts
================================================
import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
  route("/", "routes/landing.tsx"),
  route("/marketplace", "routes/marketplace.tsx"),
  route("/login", "routes/login.tsx"),
  route("/projects", "routes/projects.tsx"),
  route("/profile", "routes/profile.tsx"),
  route("/project/:id", "routes/project.$id.tsx", [
    index("components/timeline/MediaBin.tsx"),
    route("text-editor", "components/media/TextEditor.tsx"),
    route("media-bin", "components/timeline/MediaBinPage.tsx"),
    route("transitions", "components/media/Transitions.tsx"),
  ]),
  route("/api/auth/*", "routes/api.auth.$.tsx"),
  route("/api/projects/*", "routes/api.projects.$.tsx"),
  route("/api/assets/*", "routes/api.assets.$.tsx"),
  route("/api/storage/*", "routes/api.storage.$.tsx"),
  route("/learn", "routes/learn.tsx"),
  route("/roadmap", "routes/roadmap.tsx"),
  route("/privacy", "routes/privacy.tsx"),
  route("/terms", "routes/terms.tsx"),
  route("*", "./NotFound.tsx"),
] satisfies RouteConfig;



================================================
FILE: app/components/chat/ChatBox.tsx
================================================
import React, { useState, useRef, useEffect } from "react";
import {
  Send,
  Bot,
  User,
  ChevronDown,
  AtSign,
  FileVideo,
  FileImage,
  Type,
  ChevronLeft,
  ChevronRight,
  RotateCcw,
} from "lucide-react";
import { Button } from "~/components/ui/button";
import {
  type MediaBinItem,
  type TimelineState,
  type ScrubberState,
} from "../timeline/types";
import { cn } from "~/lib/utils";
import axios from "axios";
import { apiUrl } from "~/utils/api";

// llm tools
import {
  llmAddScrubberToTimeline,
  llmMoveScrubber,
  llmAddScrubberByName,
  llmDeleteScrubbersInTrack,
} from "~/utils/llm-handler";

interface Message {
  id: string;
  content: string;
  isUser: boolean;
  timestamp: Date;
}

interface ChatBoxProps {
  className?: string;
  mediaBinItems: MediaBinItem[];
  handleDropOnTrack: (
    item: MediaBinItem,
    trackId: string,
    dropLeftPx: number
  ) => void;
  isMinimized?: boolean;
  onToggleMinimize?: () => void;
  messages: Message[];
  onMessagesChange: (messages: Message[]) => void;
  timelineState: TimelineState;
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void;
  handleDeleteScrubber?: (scrubberId: string) => void;
}

export function ChatBox({
  className = "",
  mediaBinItems,
  handleDropOnTrack,
  isMinimized = false,
  onToggleMinimize,
  messages,
  onMessagesChange,
  timelineState,
  handleUpdateScrubber,
  handleDeleteScrubber,
}: ChatBoxProps) {
  const [inputValue, setInputValue] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const [showMentions, setShowMentions] = useState(false);
  const [showSendOptions, setShowSendOptions] = useState(false);
  const [mentionQuery, setMentionQuery] = useState("");
  const [selectedMentionIndex, setSelectedMentionIndex] = useState(0);
  const [cursorPosition, setCursorPosition] = useState(0);
  const [textareaHeight, setTextareaHeight] = useState(36); // Starting height for proper size
  const [sendWithMedia, setSendWithMedia] = useState(false); // Track send mode
  const [mentionedItems, setMentionedItems] = useState<MediaBinItem[]>([]); // Store actual mentioned items
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const mentionsRef = useRef<HTMLDivElement>(null);
  const sendOptionsRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when new messages are added
  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages, isTyping]);

  // Click outside handler for send options
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        sendOptionsRef.current &&
        !sendOptionsRef.current.contains(event.target as Node)
      ) {
        setShowSendOptions(false);
      }
    };

    if (showSendOptions) {
      document.addEventListener("mousedown", handleClickOutside);
      return () =>
        document.removeEventListener("mousedown", handleClickOutside);
    }
  }, [showSendOptions]);

  // Filter media bin items based on mention query
  const filteredMentions = mediaBinItems.filter((item) =>
    item.name.toLowerCase().includes(mentionQuery.toLowerCase())
  );

  // Handle input changes and @ mention detection
  const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    const cursorPos = e.target.selectionStart || 0;

    setInputValue(value);
    setCursorPosition(cursorPos);

    // Auto-resize textarea
    const textarea = e.target;
    textarea.style.height = "auto";
    const newHeight = Math.min(textarea.scrollHeight, 96); // max about 4 lines
    textarea.style.height = newHeight + "px";
    setTextareaHeight(newHeight);

    // Clean up mentioned items that are no longer in the text
    const mentionPattern = /@(\w+(?:\s+\w+)*)/g;
    const currentMentions = Array.from(value.matchAll(mentionPattern)).map(
      (match) => match[1]
    );
    setMentionedItems((prev) =>
      prev.filter((item) =>
        currentMentions.some(
          (mention) => mention.toLowerCase() === item.name.toLowerCase()
        )
      )
    );

    // Check for @ mentions
    const beforeCursor = value.slice(0, cursorPos);
    const lastAtIndex = beforeCursor.lastIndexOf("@");

    if (lastAtIndex !== -1) {
      const afterAt = beforeCursor.slice(lastAtIndex + 1);
      // Only show mentions if @ is at start or after whitespace, and no spaces after @
      const isValidMention =
        (lastAtIndex === 0 || /\s/.test(beforeCursor[lastAtIndex - 1])) &&
        !afterAt.includes(" ");

      if (isValidMention) {
        setMentionQuery(afterAt);
        setShowMentions(true);
        setSelectedMentionIndex(0);
      } else {
        setShowMentions(false);
      }
    } else {
      setShowMentions(false);
    }
  };

  // Insert mention into input
  const insertMention = (item: MediaBinItem) => {
    const beforeCursor = inputValue.slice(0, cursorPosition);
    const afterCursor = inputValue.slice(cursorPosition);
    const lastAtIndex = beforeCursor.lastIndexOf("@");

    const newValue =
      beforeCursor.slice(0, lastAtIndex) + `@${item.name} ` + afterCursor;
    setInputValue(newValue);
    setShowMentions(false);

    // Store the actual item reference for later use
    setMentionedItems((prev) => {
      // Avoid duplicates
      if (!prev.find((existingItem) => existingItem.id === item.id)) {
        return [...prev, item];
      }
      return prev;
    });

    // Focus back to input
    setTimeout(() => {
      inputRef.current?.focus();
      const newCursorPos = lastAtIndex + item.name.length + 2;
      inputRef.current?.setSelectionRange(newCursorPos, newCursorPos);
    }, 0);
  };

  const handleSendMessage = async (includeAllMedia = false) => {
    if (!inputValue.trim()) return;

    let messageContent = inputValue.trim();
    let itemsToSend = mentionedItems;

    // If sending with all media, include all media items
    if (includeAllMedia && mediaBinItems.length > 0) {
      const mediaList = mediaBinItems.map((item) => `@${item.name}`).join(" ");
      messageContent = `${messageContent} ${mediaList}`;
      // Add all media items to the items to send
      itemsToSend = [
        ...mentionedItems,
        ...mediaBinItems.filter(
          (item) =>
            !mentionedItems.find((mentioned) => mentioned.id === item.id)
        ),
      ];
    }

    const userMessage: Message = {
      id: Date.now().toString(),
      content: messageContent,
      isUser: true,
      timestamp: new Date(),
    };

    onMessagesChange([...messages, userMessage]);
    setInputValue("");
    setMentionedItems([]); // Clear mentioned items after sending
    setIsTyping(true);

    // Reset textarea height
    if (inputRef.current) {
      inputRef.current.style.height = "36px"; // Back to normal height
      setTextareaHeight(36);
    }

    try {
      // Use the stored mentioned items to get their IDs
      const mentionedScrubberIds = itemsToSend.map((item) => item.id);

      // Build short chat history to give context to the backend
      const history = messages.slice(-10).map((m) => ({
        role: m.isUser ? "user" : "assistant",
        content: m.content,
        timestamp: m.timestamp,
      }));

      // Make API call to the backend
      const response = await axios.post(apiUrl("/ai", true), {
        message: messageContent,
        mentioned_scrubber_ids: mentionedScrubberIds,
        timeline_state: timelineState,
        mediabin_items: mediaBinItems,
        chat_history: history,
      });

      const functionCallResponse = response.data;
      let aiResponseContent = "";

      // Handle the function call based on function_name
      if (functionCallResponse.function_call) {
        const { function_call } = functionCallResponse;

        try {
          if (function_call.function_name === "LLMAddScrubberToTimeline") {
            // Find the media item by ID
            const mediaItem = mediaBinItems.find(
              (item) => item.id === function_call.scrubber_id
            );

            if (!mediaItem) {
              aiResponseContent = `❌ Error: Media item with ID "${function_call.scrubber_id}" not found in the media bin.`;
            } else {
              // Execute the function
              llmAddScrubberToTimeline(
                function_call.scrubber_id,
                mediaBinItems,
                function_call.track_id,
                function_call.drop_left_px,
                handleDropOnTrack
              );

              aiResponseContent = `✅ Successfully added "${mediaItem.name}" to ${function_call.track_id} at position ${function_call.drop_left_px}px.`;
            }
          } else if (function_call.function_name === "LLMMoveScrubber") {
            // Execute move scrubber operation
            llmMoveScrubber(
              function_call.scrubber_id,
              function_call.new_position_seconds,
              function_call.new_track_number,
              function_call.pixels_per_second,
              timelineState,
              handleUpdateScrubber
            );

            // Try to locate the scrubber name for a nicer message
            const allScrubbers = timelineState.tracks.flatMap(
              (t) => t.scrubbers
            );
            const moved = allScrubbers.find(
              (s) => s.id === function_call.scrubber_id
            );
            const movedName = moved ? moved.name : function_call.scrubber_id;
            aiResponseContent = `✅ Moved "${movedName}" to track ${function_call.new_track_number} at ${function_call.new_position_seconds}s.`;
          } else if (function_call.function_name === "LLMAddScrubberByName") {
            // Add media by name with defaults
            llmAddScrubberByName(
              function_call.scrubber_name,
              mediaBinItems,
              function_call.track_number,
              function_call.position_seconds,
              function_call.pixels_per_second ?? 100,
              handleDropOnTrack
            );

            aiResponseContent = `✅ Added "${function_call.scrubber_name}" to track ${function_call.track_number} at ${function_call.position_seconds}s.`;
          } else if (
            function_call.function_name === "LLMDeleteScrubbersInTrack"
          ) {
            if (!handleDeleteScrubber) {
              throw new Error("Delete handler is not available");
            }
            llmDeleteScrubbersInTrack(
              function_call.track_number,
              timelineState,
              handleDeleteScrubber
            );
            aiResponseContent = `✅ Removed all scrubbers in track ${function_call.track_number}.`;
          } else {
            aiResponseContent = `❌ Unknown function: ${function_call.function_name}`;
          }
        } catch (error) {
          aiResponseContent = `❌ Error executing function: ${
            error instanceof Error ? error.message : "Unknown error"
          }`;
        }
      } else if (functionCallResponse.assistant_message) {
        aiResponseContent = functionCallResponse.assistant_message;
      } else {
        aiResponseContent =
          "I understand your request, but I couldn't determine a specific action to take. Could you please be more specific?";
      }

      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: aiResponseContent,
        isUser: false,
        timestamp: new Date(),
      };

      onMessagesChange([...messages, userMessage, aiMessage]);
    } catch (error) {
      console.error("Error calling AI API:", error);

      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: `❌ Sorry, I encountered an error while processing your request. Please try again.`,
        isUser: false,
        timestamp: new Date(),
      };

      onMessagesChange([...messages, userMessage, errorMessage]);
    } finally {
      setIsTyping(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (showMentions && filteredMentions.length > 0) {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setSelectedMentionIndex((prev) =>
          prev < filteredMentions.length - 1 ? prev + 1 : 0
        );
        return;
      }
      if (e.key === "ArrowUp") {
        e.preventDefault();
        setSelectedMentionIndex((prev) =>
          prev > 0 ? prev - 1 : filteredMentions.length - 1
        );
        return;
      }
      if (e.key === "Enter") {
        e.preventDefault();
        insertMention(filteredMentions[selectedMentionIndex]);
        return;
      }
      if (e.key === "Escape") {
        e.preventDefault();
        setShowMentions(false);
        return;
      }
    }

    if (e.key === "Enter") {
      if (e.shiftKey) {
        // Allow default behavior for Shift+Enter (new line)
        return;
      } else {
        // Send message on Enter
        e.preventDefault();
        handleSendMessage(sendWithMedia);
      }
    }
  };

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  };

  return (
    <div className={`h-full flex flex-col bg-background ${className}`}>
      {/* Chat Header */}
      <div className="h-9 border-b border-border/50 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 flex items-center justify-between px-3 shrink-0">
        <div className="flex items-center gap-2">
          <Bot className="h-3.5 w-3.5 text-muted-foreground" />
          <span className="text-sm font-medium tracking-tight">Ask Kimu</span>
        </div>

        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onMessagesChange([])}
            className="h-6 w-6 p-0 text-muted-foreground hover:text-foreground"
            title="Clear chat"
          >
            <RotateCcw className="h-3 w-3" />
          </Button>
          {onToggleMinimize && (
            <Button
              variant="ghost"
              size="sm"
              onClick={onToggleMinimize}
              className="h-6 w-6 p-0 text-muted-foreground hover:text-foreground"
              title={isMinimized ? "Expand chat" : "Minimize chat"}
            >
              {isMinimized ? (
                <ChevronLeft className="h-3 w-3" />
              ) : (
                <ChevronRight className="h-3 w-3" />
              )}
            </Button>
          )}
        </div>
      </div>

      {/* Content Area */}
      <div className="flex-1 flex flex-col">
        {messages.length === 0 ? (
          // Default clean state - Copilot style
          <div className="flex-1 flex flex-col items-center justify-center p-6 text-center">
            <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center mb-4">
              <Bot className="h-6 w-6 text-primary" />
            </div>
            <h2 className="text-lg font-semibold mb-2">Ask Kimu</h2>
            <p className="text-sm text-muted-foreground mb-8 max-w-xs leading-relaxed">
              Kimu is your AI assistant for video editing. Ask questions, get
              help with timeline operations, or request specific edits.
            </p>
            <div className="space-y-2 text-xs text-muted-foreground">
              <div className="flex items-center gap-2">
                <AtSign className="h-3 w-3" />
                <span>to chat with media</span>
              </div>
              <div className="flex items-center gap-2">
                <kbd className="px-1.5 py-0.5 text-xs bg-muted rounded">
                  Enter
                </kbd>
                <span>to send</span>
              </div>
              <div className="flex items-center gap-2">
                <kbd className="px-1.5 py-0.5 text-xs bg-muted rounded">
                  Shift
                </kbd>
                <span>+</span>
                <kbd className="px-1.5 py-0.5 text-xs bg-muted rounded">
                  Enter
                </kbd>
                <span>for new line</span>
              </div>
            </div>
          </div>
        ) : (
          // Messages Area
          <div
            ref={scrollContainerRef}
            className="flex-1 overflow-y-auto p-3 scroll-smooth"
            style={{ maxHeight: "calc(100vh - 200px)" }}
          >
            <div className="space-y-3">
              {messages.map((message) => (
                <div
                  key={message.id}
                  className={`flex ${
                    message.isUser ? "justify-end" : "justify-start"
                  }`}
                >
                  <div
                    className={`max-w-[80%] rounded-lg px-3 py-2 text-xs ${
                      message.isUser
                        ? "bg-primary text-primary-foreground ml-8"
                        : "bg-muted mr-8"
                    }`}
                  >
                    <div className="flex items-start gap-2">
                      {!message.isUser && (
                        <Bot className="h-3 w-3 mt-0.5 text-muted-foreground shrink-0" />
                      )}
                      <div className="flex-1 min-w-0">
                        <p className="leading-relaxed break-words overflow-wrap-anywhere">
                          {message.content}
                        </p>
                        <span className="text-xs opacity-70 mt-1 block">
                          {formatTime(message.timestamp)}
                        </span>
                      </div>
                      {message.isUser && (
                        <User className="h-3 w-3 mt-0.5 text-primary-foreground/70 shrink-0" />
                      )}
                    </div>
                  </div>
                </div>
              ))}

              {/* Typing Indicator */}
              {isTyping && (
                <div className="flex justify-start">
                  <div className="max-w-[80%] rounded-lg px-3 py-2 text-xs bg-muted mr-8">
                    <div className="flex items-center gap-2">
                      <Bot className="h-3 w-3 text-muted-foreground shrink-0" />
                      <div className="flex space-x-1">
                        <div
                          className="w-1 h-1 bg-muted-foreground rounded-full animate-bounce"
                          style={{ animationDelay: "0ms" }}
                        />
                        <div
                          className="w-1 h-1 bg-muted-foreground rounded-full animate-bounce"
                          style={{ animationDelay: "150ms" }}
                        />
                        <div
                          className="w-1 h-1 bg-muted-foreground rounded-full animate-bounce"
                          style={{ animationDelay: "300ms" }}
                        />
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Invisible element to scroll to */}
              <div ref={messagesEndRef} />
            </div>
          </div>
        )}
      </div>

      {/* Input Area with enhanced overlap effect */}
      <div className="relative bg-gradient-to-t from-background to-background/50 p-3 border-t border-border/30 backdrop-blur-sm -mt-2 pt-4">
        {/* Mentions Dropdown */}
        {showMentions && filteredMentions.length > 0 && (
          <div
            ref={mentionsRef}
            className="absolute bottom-full left-4 right-4 mb-2 bg-background border border-border/50 rounded-lg shadow-lg max-h-40 overflow-y-auto z-50"
          >
            {filteredMentions.map((item, index) => (
              <div
                key={item.id}
                className={`px-3 py-2 text-xs cursor-pointer flex items-center gap-2 ${
                  index === selectedMentionIndex
                    ? "bg-accent text-accent-foreground"
                    : "hover:bg-muted"
                }`}
                onClick={() => insertMention(item)}
              >
                <div className="w-6 h-6 bg-muted/50 rounded flex items-center justify-center">
                  {item.mediaType === "video" ? (
                    <FileVideo className="h-3 w-3 text-muted-foreground" />
                  ) : item.mediaType === "image" ? (
                    <FileImage className="h-3 w-3 text-muted-foreground" />
                  ) : (
                    <Type className="h-3 w-3 text-muted-foreground" />
                  )}
                </div>
                <span className="flex-1 truncate">{item.name}</span>
                <span className="text-xs text-muted-foreground">
                  {item.mediaType}
                </span>
              </div>
            ))}
          </div>
        )}

        {/* Send Options Dropdown */}
        {showSendOptions && (
          <div
            ref={sendOptionsRef}
            className="absolute bottom-full right-4 mb-2 bg-background border border-border/50 rounded-md shadow-lg z-50 min-w-48"
          >
            <div className="p-1">
              <div
                className="px-3 py-2 text-xs cursor-pointer hover:bg-muted rounded flex items-center justify-between"
                onClick={() => {
                  setSendWithMedia(false);
                  setShowSendOptions(false);
                  handleSendMessage(false);
                }}
              >
                <span>Send</span>
                <span className="text-xs text-muted-foreground font-mono">
                  Enter
                </span>
              </div>
              <div
                className="px-3 py-2 text-xs cursor-pointer hover:bg-muted rounded flex items-center justify-between"
                onClick={() => {
                  setSendWithMedia(true);
                  setShowSendOptions(false);
                  handleSendMessage(true);
                }}
              >
                <span>Send with all Media</span>
              </div>
              <div
                className="px-3 py-2 text-xs cursor-pointer hover:bg-muted rounded flex items-center justify-between"
                onClick={() => {
                  // Clear current messages and send to new chat
                  onMessagesChange([]);
                  setShowSendOptions(false);
                  handleSendMessage(false);
                }}
              >
                <span>Send to New Chat</span>
              </div>
            </div>
          </div>
        )}

        {/* Input container with subtle shadow and better styling */}
        <div className="relative border border-border/60 rounded-lg bg-background/90 backdrop-blur-sm focus-within: focus-within:border-ring transition-all duration-200 shadow-sm">
          {/* Full-width textarea */}
          <textarea
            ref={inputRef}
            value={inputValue}
            onChange={handleInputChange}
            onKeyDown={handleKeyPress}
            placeholder="Ask Kimu..."
            className={cn(
              "w-full min-h-8 max-h-20 resize-none text-xs bg-transparent border-0 px-3 pt-2.5 pb-1 placeholder:text-muted-foreground/60 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50",
              "transition-all duration-200 leading-relaxed"
            )}
            disabled={isTyping}
            rows={1}
            style={{ height: `${Math.max(textareaHeight, 32)}px` }}
          />

          {/* Buttons row below text with refined styling */}
          <div className="flex items-center justify-between px-2.5 pb-2 pt-0">
            {/* @ Button - left side, smaller */}
            <Button
              variant="ghost"
              size="sm"
              className="h-6 w-6 p-0 text-muted-foreground/70 hover:text-foreground hover:bg-muted/50"
              onClick={() => {
                if (inputRef.current) {
                  const cursorPos =
                    inputRef.current.selectionStart || inputValue.length;
                  const newValue =
                    inputValue.slice(0, cursorPos) +
                    "@" +
                    inputValue.slice(cursorPos);
                  setInputValue(newValue);
                  const newCursorPos = cursorPos + 1;
                  setCursorPosition(newCursorPos);

                  // Trigger mentions dropdown immediately
                  setMentionQuery("");
                  setShowMentions(true);
                  setSelectedMentionIndex(0);

                  setTimeout(() => {
                    inputRef.current?.focus();
                    inputRef.current?.setSelectionRange(
                      newCursorPos,
                      newCursorPos
                    );
                  }, 0);
                }
              }}
            >
              <AtSign className="h-2.5 w-2.5" />
            </Button>

            {/* Send buttons - right side, smaller and refined */}
            <div className="flex items-center gap-0.5">
              <Button
                onClick={() => handleSendMessage(sendWithMedia)}
                disabled={!inputValue.trim() || isTyping}
                size="sm"
                className="h-6 px-2 bg-transparent hover:bg-primary/10 text-primary hover:text-primary text-xs"
                variant="ghost"
              >
                <Send className="h-2.5 w-2.5" />
              </Button>
              <Button
                variant="ghost"
                size="sm"
                className="h-6 w-6 p-0 text-muted-foreground/70 hover:text-foreground hover:bg-muted/50"
                disabled={isTyping}
                onClick={() => setShowSendOptions(!showSendOptions)}
              >
                <ChevronDown className="h-2.5 w-2.5" />
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}



================================================
FILE: app/components/editor/LeftPanel.tsx
================================================
import React from "react";
import { Link, Outlet, useLocation } from "react-router";
import { FileImage, Type, BetweenVerticalEnd } from "lucide-react";
import { type MediaBinItem } from "~/components/timeline/types";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "~/components/ui/tabs";

interface LeftPanelProps {
  mediaBinItems: MediaBinItem[];
  isMediaLoading?: boolean;
  onAddMedia: (file: File) => void;
  onAddText: (
    textContent: string,
    fontSize: number,
    fontFamily: string,
    color: string,
    textAlign: "left" | "center" | "right",
    fontWeight: "normal" | "bold"
  ) => void;
  contextMenu: {
    x: number;
    y: number;
    item: MediaBinItem;
  } | null;
  handleContextMenu: (e: React.MouseEvent, item: MediaBinItem) => void;
  handleDeleteFromContext: () => void;
  handleSplitAudioFromContext: () => void;
  handleCloseContextMenu: () => void;
}

export default function LeftPanel({
  mediaBinItems,
  isMediaLoading,
  onAddMedia,
  onAddText,
  contextMenu,
  handleContextMenu,
  handleDeleteFromContext,
  handleSplitAudioFromContext,
  handleCloseContextMenu,
}: LeftPanelProps) {
  const location = useLocation();

  // Determine active tab based on current route
  const getActiveTab = () => {
    if (location.pathname.includes("/media-bin")) return "media-bin";
    if (location.pathname.includes("/text-editor")) return "text-editor";
    if (location.pathname.includes("/transitions")) return "transitions";
    return "media-bin"; // default
  };

  const activeTab = getActiveTab();

  return (
    <div className="h-full flex flex-col bg-background">
      <Tabs value={activeTab} className="h-full flex flex-col">
        {/* Tab Headers */}
        <div className="border-b border-border bg-muted/30">
          <TabsList className="grid w-full grid-cols-3 h-9 bg-transparent p-0">
            <TabsTrigger
              value="media-bin"
              asChild
              className="h-8 text-xs data-[state=active]:bg-background data-[state=active]:shadow-sm"
            >
              <Link to="media-bin" className="flex items-center gap-1.5">
                <FileImage className="h-3 w-3" />
              </Link>
            </TabsTrigger>
            <TabsTrigger
              value="text-editor"
              asChild
              className="h-8 text-xs data-[state=active]:bg-background data-[state=active]:shadow-sm"
            >
              <Link to="text-editor" className="flex items-center gap-1.5">
                <Type className="h-3 w-3" />
              </Link>
            </TabsTrigger>
            <TabsTrigger
              value="transitions"
              asChild
              className="h-8 text-xs data-[state=active]:bg-background data-[state=active]:shadow-sm"
            >
              <Link to="transitions" className="flex items-center gap-1.5">
                <BetweenVerticalEnd className="h-3 w-3" />
              </Link>
            </TabsTrigger>
          </TabsList>
        </div>

        {/* Tab Content */}
        <div className="flex-1 overflow-hidden">
          <Outlet
            context={{
              // MediaBin props
              mediaBinItems,
              isMediaLoading,
              onAddMedia,
              onAddText,
              contextMenu,
              handleContextMenu,
              handleDeleteFromContext,
              handleSplitAudioFromContext,
              handleCloseContextMenu,
            }}
          />
        </div>
      </Tabs>
    </div>
  );
}



================================================
FILE: app/components/media/TextEditor.tsx
================================================
import React, { useState } from "react";
import { useOutletContext, useNavigate } from "react-router";
import { Button } from "~/components/ui/button";
import { Input } from "~/components/ui/input";
import { Label } from "~/components/ui/label";
import { Badge } from "~/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "~/components/ui/card";
import { Separator } from "~/components/ui/separator";
import { AlignLeft, AlignCenter, AlignRight, Bold, ChevronDown, Type, Plus } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from "~/components/ui/dropdown-menu";

interface TextEditorProps {
  onAddText: (
    textContent: string,
    fontSize: number,
    fontFamily: string,
    color: string,
    textAlign: "left" | "center" | "right",
    fontWeight: "normal" | "bold",
  ) => void;
}

export default function TextEditor() {
  const { onAddText } = useOutletContext<TextEditorProps>();
  const navigate = useNavigate();

  const [textContent, setTextContent] = useState("Hello World");
  const [fontSize, setFontSize] = useState(48);
  const [fontFamily, setFontFamily] = useState("Arial");
  const [color, setColor] = useState("#ffffff");
  const [textAlign, setTextAlign] = useState<"left" | "center" | "right">("center");
  const [fontWeight, setFontWeight] = useState<"normal" | "bold">("normal");

  const availableFonts = [
    { label: "Arial", value: "Arial, Helvetica, sans-serif" },
    { label: "Helvetica", value: "Helvetica, Arial, sans-serif" },
    { label: "Times New Roman", value: "'Times New Roman', Times, serif" },
    { label: "Georgia", value: "Georgia, 'Times New Roman', serif" },
    { label: "Verdana", value: "Verdana, Geneva, sans-serif" },
    { label: "Impact", value: "Impact, Charcoal, sans-serif" },
  ];

  const handleAddText = () => {
    if (textContent.trim()) {
      onAddText(textContent, fontSize, fontFamily, color, textAlign, fontWeight);
      navigate("../media-bin");
    }
  };

  return (
    <div className="h-full flex flex-col bg-background">
      <div className="flex-1 overflow-y-auto p-3">
        <Card className="border-border/50">
          <CardHeader className="pb-3">
            <div className="flex items-center gap-2">
              <Type className="h-4 w-4 text-primary" />
              <CardTitle className="text-sm">Text Properties</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Text Content */}
            <div className="space-y-2">
              <Label className="text-xs font-medium">Content</Label>
              <textarea
                value={textContent}
                onChange={(e) => setTextContent(e.target.value)}
                className="w-full h-20 p-3 text-sm bg-muted/50 border border-border rounded-md text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none"
                placeholder="Enter your text..."
              />
            </div>

            {/* Font Size & Family Row */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label className="text-xs font-medium">Size</Label>
                <Input
                  type="number"
                  min="8"
                  max="200"
                  value={fontSize}
                  onChange={(e) => setFontSize(parseInt(e.target.value) || 48)}
                  className="h-8 text-sm"
                />
              </div>
              <div className="space-y-2">
                <Label className="text-xs font-medium">Font</Label>
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button
                      variant="ghost"
                      className="w-full h-8 px-2 text-sm bg-muted/50 border border-border rounded-md text-foreground justify-between hover:bg-muted/70"
                      style={{ fontFamily: fontFamily }}
                      aria-label="Select font">
                      <span className="truncate">
                        {availableFonts.find((f) => f.value === fontFamily)?.label || fontFamily}
                      </span>
                      <ChevronDown className="h-3.5 w-3.5 ml-2 opacity-70" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent className="rounded-md p-1 min-w-[12rem]">
                    {availableFonts.map((font) => (
                      <DropdownMenuItem
                        key={font.label}
                        onSelect={() => setFontFamily(font.value)}
                        className="cursor-pointer"
                        style={{ fontFamily: font.value }}>
                        {font.label}
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>

            <Separator className="my-4" />

            {/* Style Controls */}
            <div className="space-y-3">
              <Label className="text-xs font-medium">Style</Label>

              {/* Text Alignment */}
              <div className="space-y-2">
                <Label className="text-xs text-muted-foreground">Alignment</Label>
                <div className="flex rounded-md border border-border overflow-hidden">
                  {(
                    [
                      { value: "left", icon: AlignLeft, label: "Left" },
                      { value: "center", icon: AlignCenter, label: "Center" },
                      { value: "right", icon: AlignRight, label: "Right" },
                    ] as const
                  ).map(({ value, icon: Icon, label }) => (
                    <Button
                      key={value}
                      variant={textAlign === value ? "default" : "ghost"}
                      size="sm"
                      onClick={() => setTextAlign(value)}
                      className="flex-1 h-8 rounded-none border-0"
                      title={label}>
                      <Icon className="h-3.5 w-3.5" />
                    </Button>
                  ))}
                </div>
              </div>

              {/* Font Weight & Color */}
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <Label className="text-xs text-muted-foreground">Weight</Label>
                  <div className="flex rounded-md border border-border overflow-hidden">
                    {(["normal", "bold"] as const).map((weight) => (
                      <Button
                        key={weight}
                        variant={fontWeight === weight ? "default" : "ghost"}
                        size="sm"
                        onClick={() => setFontWeight(weight)}
                        className="flex-1 h-8 rounded-none border-0 text-xs"
                        title={weight}>
                        {weight === "normal" ? "Normal" : <Bold className="h-3.5 w-3.5" />}
                      </Button>
                    ))}
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-xs text-muted-foreground">Color</Label>
                  <div className="flex items-center gap-2">
                    <input
                      type="color"
                      value={color}
                      onChange={(e) => setColor(e.target.value)}
                      className="w-full h-8 bg-muted/50 border border-border rounded-md cursor-pointer"
                    />
                    <Badge variant="outline" className="text-xs font-mono">
                      {color.toUpperCase()}
                    </Badge>
                  </div>
                </div>
              </div>
            </div>

            <Separator className="my-4" />

            {/* Preview */}
            <div className="space-y-2">
              <Label className="text-xs font-medium">Preview</Label>
              <div
                className="w-full h-20 bg-muted/30 border border-border rounded-md flex items-center justify-center p-3"
                style={{
                  textAlign: textAlign,
                  fontSize: `${Math.min(fontSize * 0.3, 18)}px`,
                  fontFamily: fontFamily,
                  fontWeight: fontWeight,
                  color: color,
                }}>
                {textContent || "Sample text"}
              </div>
            </div>

            {/* Add Button */}
            <Button onClick={handleAddText} disabled={!textContent.trim()} className="w-full h-9" size="sm">
              <Plus className="h-3.5 w-3.5 mr-2" />
              Add Text to Timeline
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}



================================================
FILE: app/components/media/Transitions.tsx
================================================
import React, { useState } from "react";
import { Card, CardContent } from "~/components/ui/card";
import { FPS } from "../timeline/types";
import { generateUUID } from "~/utils/uuid";

// Data router loader (no data needed, ensures route is compatible with data router)
export function loader() {
    return null;
}

type TransitionType = {
    type: "fade" | "wipe" | "clockWipe" | "slide" | "flip" | "iris";
    name: string;
    description: string;
};

const transitionTypes: TransitionType[] = [
    {
        type: "fade",
        name: "fade()",
        description: "Animate the opacity of the scenes",
    },
    {
        type: "slide",
        name: "slide()",
        description: "Slide in and push out the previous scene",
    },
    {
        type: "wipe",
        name: "wipe()",
        description: "Slide over the previous scene",
    },
    {
        type: "flip",
        name: "flip()",
        description: "Rotate the previous scene",
    },
    {
        type: "clockWipe",
        name: "clockWipe()",
        description: "Reveal the new scene in a circular movement",
    },
    {
        type: "iris",
        name: "iris()",
        description: "Reveal the scene through a circular mask from center",
    },
];

const TransitionThumbnail = ({ transition, isSelected, onClick }: {
    transition: TransitionType;
    isSelected: boolean;
    onClick: () => void;
}) => {
    const handleDragStart = (e: React.DragEvent) => {
        const transitionData = {
            id: generateUUID(),
            type: "transition",
            presentation: transition.type,
            timing: "linear",
            durationInFrames: 1 * FPS,
            leftScrubberId: null,
            rightScrubberId: null,
        };
        e.dataTransfer.setData("application/json", JSON.stringify(transitionData));
        e.dataTransfer.effectAllowed = "copy";
    };

    const renderTransitionEffect = () => {
        const baseClasses = "absolute rounded-sm";
        
        switch (transition.type) {
            case "fade":
                return (
                    <>
                        <div className={`${baseClasses} w-full h-full bg-blue-500`} />
                        <div className={`${baseClasses} w-full h-full bg-blue-300 opacity-50`} />
                    </>
                );
            case "slide":
                return (
                    <>
                        <div className={`${baseClasses} w-3/4 h-full right-0 bg-pink-400`} />
                        <div className={`${baseClasses} w-3/4 h-full left-0 bg-pink-200`} />
                    </>
                );
            case "wipe":
                return (
                    <>
                        <div className={`${baseClasses} w-full h-full bg-blue-500`} />
                        <div className={`${baseClasses} w-2/3 h-full left-0 bg-blue-300`} />
                    </>
                );
            case "flip":
                return (
                    <>
                        <div className={`${baseClasses} w-full h-full bg-blue-500 transform -skew-y-6`} />
                        <div className={`${baseClasses} w-full h-full bg-blue-300 transform skew-y-6 opacity-70`} />
                    </>
                );
            case "clockWipe":
                return (
                    <>
                        <div className={`${baseClasses} w-full h-full bg-blue-500`} />
                        <div
                            className={`${baseClasses} w-full h-full bg-blue-300`}
                            style={{
                                clipPath: "polygon(50% 50%, 50% 0%, 100% 0%, 100% 100%, 0% 100%, 0% 50%)"
                            }}
                        />
                    </>
                );
            case "iris":
                return (
                    <>
                        <div className={`${baseClasses} w-full h-full bg-blue-500`} />
                        <div
                            className={`${baseClasses} w-full h-full bg-blue-300`}
                            style={{
                                clipPath: "circle(40% at 50% 50%)"
                            }}
                        />
                    </>
                );
        }
    };

    return (
        <Card
            className={`cursor-grab active:cursor-grabbing transition-all hover:shadow-md ${isSelected ? 'ring-2 ring-primary shadow-md' : 'hover:ring-1 hover:ring-border'
                }`}
            onClick={onClick}
            draggable={true}
            onDragStart={handleDragStart}
        >
            <CardContent className="p-3">
                <div className="space-y-2">
                    {/* Thumbnail */}
                    <div className="relative w-full h-16 bg-muted rounded-sm overflow-hidden">
                        {renderTransitionEffect()}
                    </div>

                    {/* Title and description */}
                    <div>
                        <div className="flex items-center gap-1">
                            <span className="text-sm font-medium text-primary">
                                {transition.name}
                            </span>
                        </div>
                        <p className="text-xs text-muted-foreground leading-tight">
                            {transition.description}
                        </p>
                    </div>
                </div>
            </CardContent>
        </Card>
    );
};

export default function Transitions() {
    const [selectedTransition, setSelectedTransition] = useState<string | null>(null);

    return (
        <div className="h-full flex flex-col bg-background">
            <div className="flex-1 overflow-y-auto p-3 space-y-4">
                {/* Transitions Grid */}
                <div className="grid grid-cols-2 gap-3">
                    {transitionTypes.map((transition) => (
                        <TransitionThumbnail
                            key={transition.type}
                            transition={transition}
                            isSelected={selectedTransition === transition.type}
                            onClick={() => setSelectedTransition(transition.type)}
                        />
                    ))}
                </div>
            </div>
        </div>
    );
}



================================================
FILE: app/components/redirects/mediaBinLoader.ts
================================================
export function loader() {
  return null;
}

export default function MediaBinRedirectPlaceholder() {
  // This component is never rendered because MediaBin is the index route.
  // Keeping a placeholder avoids duplicate route IDs with the index element.
  return null;
}



================================================
FILE: app/components/timeline/DimensionControls.tsx
================================================
import React from "react"

interface DimensionControlsProps {
  width: number
  height: number
  onWidthChange: (width: number) => void
  onHeightChange: (height: number) => void
  isAutoSize: boolean
  onAutoSizeChange: (auto: boolean) => void
}

export const DimensionControls: React.FC<DimensionControlsProps> = ({
  width,
  height,
  onWidthChange,
  onHeightChange,
  isAutoSize,
  onAutoSizeChange,
}) => {
  return (
    <div className="flex items-center space-x-2 bg-gray-100 px-3 py-2 rounded-lg">
      <label className="text-sm font-medium text-gray-700">Size:</label>
      <input
        type="number"
        value={width}
        onChange={(e) => onWidthChange(parseInt(e.target.value) || 1920)}
        disabled={isAutoSize}
        className={`w-20 px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500 ${
          isAutoSize ? 'bg-gray-200 text-gray-400 cursor-not-allowed' : ''
        }`}
        min="1"
        max="7680"
      />
      <span className="text-gray-500">×</span>
      <input
        type="number"
        value={height}
        onChange={(e) => onHeightChange(parseInt(e.target.value) || 1080)}
        disabled={isAutoSize}
        className={`w-20 px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500 ${
          isAutoSize ? 'bg-gray-200 text-gray-400 cursor-not-allowed' : ''
        }`}
        min="1"
        max="4320"
      />
      <div className="flex items-center space-x-1 ml-2">
        <input
          type="checkbox"
          id="auto-size"
          checked={isAutoSize}
          onChange={(e) => onAutoSizeChange(e.target.checked)}
          className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
        />
        <label htmlFor="auto-size" className="text-sm font-medium text-gray-700 cursor-pointer">
          Auto
        </label>
      </div>
    </div>
  )
} 


================================================
FILE: app/components/timeline/MediaActionButtons.tsx
================================================
import React from "react"

interface MediaActionButtonsProps {
  onAddMedia: () => void
  onAddText: () => void
}

export const MediaActionButtons: React.FC<MediaActionButtonsProps> = ({
  onAddMedia,
  onAddText,
}) => {
  return (
    <div className="flex space-x-2">
      <button
        onClick={onAddMedia}
        className="px-4 py-2 bg-gray-700 border border-gray-600 text-gray-100 rounded hover:bg-gray-600 hover:border-blue-500 hover:text-white transition-colors cursor-pointer"
      >
        Add Media
      </button>
      <button
        onClick={onAddText}
        className="px-4 py-2 bg-gray-700 border border-gray-600 text-gray-100 rounded hover:bg-gray-600 hover:border-blue-500 hover:text-white transition-colors cursor-pointer"
      >
        Add Text
      </button>
    </div>
  )
} 


================================================
FILE: app/components/timeline/MediaBin.tsx
================================================
import { useOutletContext } from "react-router";
import { useMemo, memo, useState, useCallback, useRef, useEffect } from "react";
import {
  FileVideo,
  FileImage,
  Type,
  Clock,
  Upload,
  Music,
  Trash2,
  SplitSquareHorizontal,
  ChevronDown,
  ChevronUp,
  List,
  Layers,
  ArrowUpDown,
  Play,
  Pause,
  Volume2,
  VolumeX,
} from "lucide-react";
import { Thumbnail } from "@remotion/player";
import { OffthreadVideo, Img, Video } from "remotion";
import { type MediaBinItem } from "./types";
import { Badge } from "~/components/ui/badge";
import { Progress } from "~/components/ui/progress";
import { Button } from "~/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "~/components/ui/dropdown-menu";

interface MediaBinProps {
  mediaBinItems: MediaBinItem[];
  isMediaLoading?: boolean;
  onAddMedia: (file: File) => Promise<void>;
  onAddText: (
    textContent: string,
    fontSize: number,
    fontFamily: string,
    color: string,
    textAlign: "left" | "center" | "right",
    fontWeight: "normal" | "bold"
  ) => void;
  contextMenu: {
    x: number;
    y: number;
    item: MediaBinItem;
  } | null;
  handleContextMenu: (e: React.MouseEvent, item: MediaBinItem) => void;
  handleDeleteFromContext: () => Promise<void>;
  handleSplitAudioFromContext: () => Promise<void>;
  handleCloseContextMenu: () => void;
}

// Memoized component for video thumbnails to prevent flickering
const VideoThumbnail = memo(
  ({
    mediaUrl,
    width,
    height,
  }: {
    mediaUrl: string;
    width: number;
    height: number;
  }) => {
    const VideoComponent = useMemo(() => {
      return () => <Video src={mediaUrl} />;
    }, [mediaUrl]);

    return (
      <div className="w-12 h-8 rounded border border-border/50 overflow-hidden bg-card">
        <Thumbnail
          component={VideoComponent}
          compositionWidth={width}
          compositionHeight={height}
          frameToDisplay={30}
          durationInFrames={1}
          fps={30}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </div>
    );
  }
);

// Compact custom audio preview (no extra containers, minimal, design-token aware)
const AudioPreview = ({ src }: { src: string }) => {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [duration, setDuration] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const [isMuted, setIsMuted] = useState(false);
  const trackRef = useRef<HTMLDivElement | null>(null);
  const [isScrubbing, setIsScrubbing] = useState(false);

  const format = (t: number) => {
    const m = Math.floor(t / 60);
    const s = Math.floor(t % 60);
    return `${m}:${s.toString().padStart(2, "0")}`;
  };

  const togglePlay = useCallback(() => {
    const el = audioRef.current;
    if (!el) return;
    if (el.paused) {
      el.play().catch(() => { });
    } else {
      el.pause();
    }
  }, []);

  const onTimeUpdate = useCallback(() => {
    const el = audioRef.current;
    if (!el) return;
    setCurrentTime(el.currentTime);
    setIsPlaying(!el.paused);
  }, []);

  const onLoaded = useCallback(() => {
    const el = audioRef.current;
    if (!el) return;
    setDuration(Number.isFinite(el.duration) ? el.duration : 0);
    setCurrentTime(el.currentTime || 0);
    setIsPlaying(!el.paused);
  }, []);

  const seekFromClientX = useCallback(
    (clientX: number) => {
      const el = audioRef.current;
      const track = trackRef.current;
      if (!el || !track || duration <= 0) return;
      const rect = track.getBoundingClientRect();
      const x = Math.max(0, Math.min(clientX - rect.left, rect.width));
      const pct = rect.width ? x / rect.width : 0;
      el.currentTime = pct * duration;
    },
    [duration]
  );

  const onPointerDownTrack = useCallback(
    (e: React.PointerEvent<HTMLDivElement>) => {
      e.preventDefault();
      (e.currentTarget as HTMLDivElement).setPointerCapture(e.pointerId);
      setIsScrubbing(true);
      seekFromClientX(e.clientX);
    },
    [seekFromClientX]
  );

  useEffect(() => {
    if (!isScrubbing) return;
    const onMove = (e: PointerEvent) => seekFromClientX(e.clientX);
    const onUp = () => setIsScrubbing(false);
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", onUp, { once: true });
    return () => {
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerup", onUp as EventListener);
    };
  }, [isScrubbing, seekFromClientX]);

  const toggleMute = useCallback(() => {
    const el = audioRef.current;
    if (!el) return;
    el.muted = !el.muted;
    setIsMuted(el.muted);
  }, []);

  return (
    <div className="w-full flex items-center gap-2 select-none">
      <Button
        variant="ghost"
        size="sm"
        className="h-7 w-7 p-0 bg-transparent hover:bg-transparent"
        onClick={togglePlay}
        title={isPlaying ? "Pause" : "Play"}
      >
        {isPlaying ? (
          <Pause className="h-3.5 w-3.5" />
        ) : (
          <Play className="h-3.5 w-3.5" />
        )}
      </Button>
      <div
        ref={trackRef}
        onPointerDown={onPointerDownTrack}
        className="relative w-full h-0.5 rounded cursor-pointer bg-black/25 dark:bg-white/25"
      >
        <div
          className="absolute left-0 top-0 h-full bg-primary rounded"
          style={{
            width: `${duration > 0
              ? (Math.min(currentTime, duration) / duration) * 100
              : 0
              }%`,
          }}
        />
      </div>
      <div className="text-[11px] tabular-nums text-muted-foreground min-w-[84px] text-right">
        {format(currentTime)} / {format(duration)}
      </div>
      <Button
        variant="ghost"
        size="sm"
        className="h-7 w-7 p-0 bg-transparent hover:bg-transparent"
        onClick={toggleMute}
        title={isMuted ? "Unmute" : "Mute"}
      >
        {isMuted ? (
          <VolumeX className="h-3.5 w-3.5" />
        ) : (
          <Volume2 className="h-3.5 w-3.5" />
        )}
      </Button>
      <audio
        ref={audioRef}
        src={src}
        onTimeUpdate={onTimeUpdate}
        onLoadedMetadata={onLoaded}
        onPlay={() => setIsPlaying(true)}
        onPause={() => setIsPlaying(false)}
        className="hidden"
      />
    </div>
  );
};

// This is required for the data router
export function loader() {
  return null;
}

export default function MediaBin() {
  const {
    mediaBinItems,
    isMediaLoading,
    onAddMedia,
    onAddText,
    contextMenu,
    handleContextMenu,
    handleDeleteFromContext,
    handleSplitAudioFromContext,
    handleCloseContextMenu,
  } = useOutletContext<MediaBinProps>();

  // Drag & Drop state for external file imports
  const [isDragOver, setIsDragOver] = useState(false);

  // Arrange & sorting state
  const [arrangeMode, setArrangeMode] = useState<"default" | "group">(
    "default"
  );
  const [sortBy, setSortBy] = useState<"default" | "name_asc" | "name_desc">(
    "default"
  );
  const [collapsed, setCollapsed] = useState<{
    [key in "videos" | "gifs" | "images" | "audio" | "text"]: boolean;
  }>({
    videos: false,
    gifs: false,
    images: false,
    audio: false,
    text: false,
  });

  const handleDragOverRoot = useCallback(
    (e: React.DragEvent<HTMLDivElement>) => {
      // Only react to file drags from OS, not internal element drags
      if (!Array.from(e.dataTransfer.types).includes("Files")) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = "copy";
      setIsDragOver(true);
    },
    []
  );

  const handleDragLeaveRoot = useCallback(
    (e: React.DragEvent<HTMLDivElement>) => {
      if (!Array.from(e.dataTransfer.types).includes("Files")) return;
      // Only reset when leaving the current target
      if (e.currentTarget.contains(e.relatedTarget as Node)) return;
      setIsDragOver(false);
    },
    []
  );

  const handleDropRoot = useCallback(
    async (e: React.DragEvent<HTMLDivElement>) => {
      if (!Array.from(e.dataTransfer.types).includes("Files")) return;
      e.preventDefault();
      setIsDragOver(false);
      const droppedFiles = Array.from(e.dataTransfer.files || []);

      const isAllowed = (file: File) => {
        const type = (file.type || "").toLowerCase();
        if (
          type.startsWith("video/") ||
          type.startsWith("audio/") ||
          type.startsWith("image/")
        ) {
          return true; // includes GIF via image/gif
        }
        // Fallback by extension when MIME is missing
        const name = file.name.toLowerCase();
        const imageExts = [
          ".png",
          ".jpg",
          ".jpeg",
          ".webp",
          ".bmp",
          ".gif",
          ".tiff",
          ".svg",
          ".heic",
          ".heif",
        ];
        const videoExts = [
          ".mp4",
          ".mov",
          ".mkv",
          ".webm",
          ".avi",
          ".m4v",
          ".wmv",
          ".mts",
          ".m2ts",
          ".3gp",
          ".flv",
        ];
        const audioExts = [
          ".mp3",
          ".wav",
          ".aac",
          ".flac",
          ".m4a",
          ".ogg",
          ".opus",
          ".aiff",
          ".aif",
          ".wma",
        ];
        const all = [...imageExts, ...videoExts, ...audioExts];
        return all.some((ext) => name.endsWith(ext));
      };

      const files = droppedFiles.filter(isAllowed);
      for (const file of files) {
        try {
          await onAddMedia(file);
        } catch (err) {
          console.error("Failed to import file via drop:", file.name, err);
        }
      }
    },
    [onAddMedia]
  );

  const getMediaIcon = (mediaType: string) => {
    switch (mediaType) {
      case "video":
        return <FileVideo className="h-4 w-4" />;
      case "image":
        return <FileImage className="h-4 w-4" />;
      case "text":
        return <Type className="h-4 w-4" />;
      case "audio":
        return <Music className="h-4 w-4" />;
      default:
        return <FileImage className="h-4 w-4" />;
    }
  };

  const isGif = (item: MediaBinItem) => {
    if (item.mediaType !== "image") return false;
    const name = (item.name || "").toLowerCase();
    const url = (item.mediaUrlLocal || item.mediaUrlRemote || "").toLowerCase();
    return name.endsWith(".gif") || url.includes(".gif");
  };

  const counts = useMemo(() => {
    const videos = mediaBinItems.filter((i) => i.mediaType === "video").length;
    const gifs = mediaBinItems.filter(isGif).length;
    const images = mediaBinItems.filter(
      (i) => i.mediaType === "image" && !isGif(i)
    ).length;
    const audio = mediaBinItems.filter((i) => i.mediaType === "audio").length;
    const text = mediaBinItems.filter((i) => i.mediaType === "text").length;
    const all = mediaBinItems.length;
    return { all, videos, images, gifs, audio, text };
  }, [mediaBinItems]);

  const defaultArrangedItems = useMemo(() => {
    if (sortBy === "name_asc")
      return [...mediaBinItems].sort((a, b) => a.name.localeCompare(b.name));
    if (sortBy === "name_desc")
      return [...mediaBinItems].sort((a, b) => b.name.localeCompare(a.name));
    return mediaBinItems;
  }, [mediaBinItems, sortBy]);

  const groupedItems = useMemo(() => {
    const videos = mediaBinItems.filter((i) => i.mediaType === "video");
    const gifs = mediaBinItems.filter(isGif);
    const images = mediaBinItems.filter(
      (i) => i.mediaType === "image" && !isGif(i)
    );
    const audio = mediaBinItems.filter((i) => i.mediaType === "audio");
    const text = mediaBinItems.filter((i) => i.mediaType === "text");

    const maybeSort = (arr: MediaBinItem[]) => {
      if (sortBy === "name_asc")
        return [...arr].sort((a, b) => a.name.localeCompare(b.name));
      if (sortBy === "name_desc")
        return [...arr].sort((a, b) => b.name.localeCompare(a.name));
      return arr;
    };

    return {
      videos: maybeSort(videos),
      gifs: maybeSort(gifs),
      images: maybeSort(images),
      audio: maybeSort(audio),
      text: maybeSort(text),
    };
  }, [mediaBinItems, sortBy]);
  const renderThumbnail = (item: MediaBinItem) => {
    const mediaUrl = item.mediaUrlLocal || item.mediaUrlRemote;

    // Show icon for uploading items
    if (item.isUploading) {
      return <Upload className="h-8 w-8 animate-pulse text-muted-foreground" />;
    }

    // Show thumbnails for different media types
    switch (item.mediaType) {
      case "video":
        if (mediaUrl) {
          return (
            <VideoThumbnail
              mediaUrl={mediaUrl}
              width={item.media_width || 1920}
              height={item.media_height || 1080}
            />
          );
        }
        return <FileVideo className="h-8 w-8 text-muted-foreground" />;

      case "image":
        if (mediaUrl) {
          return (
            <div className="w-12 h-8 rounded border border-border/50 overflow-hidden bg-card">
              <img
                src={mediaUrl}
                alt={item.name}
                className="w-full h-full object-cover"
                onError={(e) => {
                  e.currentTarget.style.display = "none";
                  e.currentTarget.nextElementSibling?.classList.remove(
                    "hidden"
                  );
                }}
              />
              <FileImage className="h-8 w-8 text-muted-foreground hidden" />
            </div>
          );
        }
        return <FileImage className="h-8 w-8 text-muted-foreground" />;

      case "text":
        return (
          <div className="w-12 h-8 rounded border border-border/50 bg-card flex items-center justify-center">
            <Type className="h-4 w-4 text-muted-foreground" />
          </div>
        );

      case "audio":
        return (
          <div className="w-12 h-8 rounded border border-border/50 bg-card flex items-center justify-center">
            <Music className="h-4 w-4 text-muted-foreground" />
          </div>
        );

      default:
        return <FileImage className="h-8 w-8 text-muted-foreground" />;
    }
  };

  // Preview overlay state
  const [previewItem, setPreviewItem] = useState<MediaBinItem | null>(null);
  const openPreview = useCallback((item: MediaBinItem) => {
    if (item.isUploading) return; // avoid preview while uploading
    setPreviewItem(item);
  }, []);
  const closePreview = useCallback(() => setPreviewItem(null), []);

  // Support closing preview with Escape key
  useEffect(() => {
    if (!previewItem) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        closePreview();
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [previewItem, closePreview]);

  // Focus overlay so onKeyDown works if needed
  const overlayRef = useRef<HTMLDivElement | null>(null);
  useEffect(() => {
    if (previewItem && overlayRef.current) {
      overlayRef.current.focus();
    }
  }, [previewItem]);

  return (
    <div
      className="h-full flex flex-col bg-background relative"
      onClick={handleCloseContextMenu}
      onDragOver={handleDragOverRoot}
      onDragEnter={handleDragOverRoot}
      onDragLeave={handleDragLeaveRoot}
      onDrop={handleDropRoot}
    >
      {/* Compact Header */}
      <div className="p-2 border-b border-border/50">
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-1.5">
            <h3 className="text-xs font-medium text-foreground">
              Media Library
            </h3>
            <Badge variant="secondary" className="text-xs h-4 px-1.5 font-mono">
              {mediaBinItems.length}
            </Badge>
          </div>
          <div className="flex items-center gap-1.5">
            {/* Arrange segmented switch - subtle, no gray bg */}
            <div className="flex items-center gap-0.5 rounded-md border border-border/30 p-0.5">
              <Button
                variant="ghost"
                size="sm"
                className={`h-5 w-5 p-0 bg-transparent hover:bg-transparent ${arrangeMode === "default"
                  ? "text-primary"
                  : "text-muted-foreground/70 hover:text-foreground"
                  }`}
                onClick={() => setArrangeMode("default")}
                title="Default order"
                aria-pressed={arrangeMode === "default"}
              >
                <List className="h-2 w-2" />
              </Button>
              <Button
                variant="ghost"
                size="sm"
                className={`h-5 w-5 p-0 bg-transparent hover:bg-transparent ${arrangeMode === "group"
                  ? "text-primary"
                  : "text-muted-foreground/70 hover:text-foreground"
                  }`}
                onClick={() => setArrangeMode("group")}
                title="Smart Group"
                aria-pressed={arrangeMode === "group"}
              >
                <Layers className="h-2 w-2" />
              </Button>
            </div>

            {/* Removed filter button per request */}

            {/* Sort dropdown */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-5 w-5 p-0 text-muted-foreground/70 hover:text-foreground bg-transparent hover:bg-transparent"
                  title="Sort"
                >
                  <ArrowUpDown className="h-3 w-3" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="min-w-[12rem]">
                <DropdownMenuLabel className="text-[11px]">
                  Sort
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  onClick={() => setSortBy("default")}
                  className={`text-[12px] gap-2 ${sortBy === "default" ? "text-primary" : ""
                    }`}
                  data-variant="ghost"
                >
                  <ArrowUpDown
                    className={`h-3 w-3 ${sortBy === "default" ? "text-primary" : ""
                      }`}
                  />{" "}
                  Original order
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => setSortBy("name_asc")}
                  className={`text-[12px] gap-2 ${sortBy === "name_asc" ? "text-primary" : ""
                    }`}
                  data-variant="ghost"
                >
                  <ChevronUp
                    className={`h-3 w-3 ${sortBy === "name_asc" ? "text-primary" : ""
                      }`}
                  />{" "}
                  Name A–Z
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => setSortBy("name_desc")}
                  className={`text-[12px] gap-2 ${sortBy === "name_desc" ? "text-primary" : ""
                    }`}
                  data-variant="ghost"
                >
                  <ChevronDown
                    className={`h-3 w-3 ${sortBy === "name_desc" ? "text-primary" : ""
                      }`}
                  />{" "}
                  Name Z–A
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </div>

      {/* Media Items */}
      <div className="flex-1 overflow-y-auto p-2 space-y-1 panel-scrollbar">
        {isMediaLoading && (
          <div className="px-0.5">
            <div className="indeterminate-line text-primary" />
          </div>
        )}
        {arrangeMode === "default" && (
          <>
            {defaultArrangedItems.map((item) => (
              <div
                key={item.id}
                className={`group p-2 border border-border/50 rounded-md transition-colors ${item.isUploading
                  ? "bg-accent/30 cursor-default"
                  : "bg-card cursor-grab hover:bg-accent/50"
                  }`}
                draggable={!item.isUploading}
                onDragStart={(e) => {
                  if (!item.isUploading) {
                    e.dataTransfer.setData(
                      "application/json",
                      JSON.stringify(item)
                    );
                    console.log("Dragging item:", item.name);
                  }
                }}
                onContextMenu={(e) => handleContextMenu(e, item)}
                onDoubleClick={() => openPreview(item)}
              >
                <div className="flex items-start gap-2">
                  <div className="flex-shrink-0">{renderThumbnail(item)}</div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p
                        className={`text-xs font-medium truncate transition-colors ${item.isUploading
                          ? "text-muted-foreground"
                          : "text-foreground group-hover:text-accent-foreground"
                          }`}
                      >
                        {item.name}
                      </p>

                      {item.isUploading &&
                        typeof item.uploadProgress === "number" && (
                          <span className="text-xs text-muted-foreground font-mono">
                            {item.uploadProgress}%
                          </span>
                        )}
                    </div>

                    {item.isUploading &&
                      typeof item.uploadProgress === "number" && (
                        <div className="mt-1 mb-1">
                          <Progress
                            value={item.uploadProgress}
                            className="h-1"
                          />
                        </div>
                      )}

                    <div className="flex items-center gap-1.5 mt-0.5">
                      <Badge
                        variant="secondary"
                        className="text-xs px-1 py-0 h-auto"
                      >
                        {item.isUploading ? "uploading" : item.mediaType}
                      </Badge>
                      {(item.mediaType === "video" || item.mediaType === "audio" || item.mediaType === "groupped_scrubber") && item.durationInSeconds > 0 && !item.isUploading && (
                        <div className="flex items-center gap-0.5 text-xs text-muted-foreground">
                          <Clock className="h-2.5 w-2.5" />
                          {item.durationInSeconds.toFixed(1)}s
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            ))}

            {defaultArrangedItems.length === 0 && (
              <div className="flex flex-col items-center justify-center py-8 text-center">
                <FileImage className="h-8 w-8 text-muted-foreground/50 mb-3" />
                <p className="text-xs text-muted-foreground">No media files</p>
                <p className="text-xs text-muted-foreground/70 mt-0.5">
                  Import videos, images, or audio to get started
                </p>
              </div>
            )}
          </>
        )}

        {arrangeMode === "group" && (
          <div className="space-y-2">
            {[
              {
                key: "videos" as const,
                title: "Videos",
                items: groupedItems.videos,
                count: counts.videos,
              },
              {
                key: "gifs" as const,
                title: "GIFs",
                items: groupedItems.gifs,
                count: counts.gifs,
              },
              {
                key: "images" as const,
                title: "Images",
                items: groupedItems.images,
                count: counts.images,
              },
              {
                key: "audio" as const,
                title: "Audio",
                items: groupedItems.audio,
                count: counts.audio,
              },
              {
                key: "text" as const,
                title: "Text",
                items: groupedItems.text,
                count: counts.text,
              },
            ]
              .filter((section) => section.count > 0)
              .map((section) => (
                <div
                  key={section.key}
                  className="rounded-lg border border-border/40 bg-card/40 overflow-hidden"
                >
                  <button
                    className="w-full flex items-center justify-between px-2.5 py-1.5 text-xs hover:bg-accent/40 transition-colors"
                    onClick={() =>
                      setCollapsed((prev) => ({
                        ...prev,
                        [section.key]: !prev[section.key],
                      }))
                    }
                  >
                    <div className="flex items-center gap-1.5 text-muted-foreground">
                      {section.key === "videos" && (
                        <FileVideo className="h-3 w-3" />
                      )}
                      {section.key === "gifs" && (
                        <FileImage className="h-3 w-3" />
                      )}
                      {section.key === "images" && (
                        <FileImage className="h-3 w-3" />
                      )}
                      {section.key === "audio" && <Music className="h-3 w-3" />}
                      {section.key === "text" && <Type className="h-3 w-3" />}
                      <span className="font-medium text-foreground/90">
                        {section.title}
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge
                        variant="secondary"
                        className="text-[10px] h-4 px-1.5 font-mono"
                      >
                        {section.count}
                      </Badge>
                      {collapsed[section.key] ? (
                        <ChevronDown className="h-3 w-3" />
                      ) : (
                        <ChevronUp className="h-3 w-3" />
                      )}
                    </div>
                  </button>
                  {!collapsed[section.key] && (
                    <div className="p-2 space-y-1.5">
                      {section.items.map((item) => (
                        <div
                          key={item.id}
                          className={`group p-2 rounded-md border border-border/40 transition-colors ${item.isUploading
                            ? "bg-accent/30 cursor-default"
                            : "bg-card hover:bg-accent/30"
                            }`}
                          draggable={!item.isUploading}
                          onDragStart={(e) => {
                            if (!item.isUploading) {
                              e.dataTransfer.setData(
                                "application/json",
                                JSON.stringify(item)
                              );
                            }
                          }}
                          onContextMenu={(e) => handleContextMenu(e, item)}
                          onDoubleClick={() => openPreview(item)}
                        >
                          <div className="flex items-start gap-2">
                            <div className="flex-shrink-0">
                              {renderThumbnail(item)}
                            </div>

                            <div className="flex-1 min-w-0">
                              <div className="flex items-center gap-2">
                                <p
                                  className={`text-xs font-medium truncate ${item.isUploading
                                    ? "text-muted-foreground"
                                    : "text-foreground"
                                    }`}
                                >
                                  {item.name}
                                </p>
                                {item.isUploading &&
                                  typeof item.uploadProgress === "number" && (
                                    <span className="text-xs text-muted-foreground font-mono">
                                      {item.uploadProgress}%
                                    </span>
                                  )}
                              </div>

                              {item.isUploading &&
                                typeof item.uploadProgress === "number" && (
                                  <div className="mt-1 mb-1">
                                    <Progress
                                      value={item.uploadProgress}
                                      className="h-1"
                                    />
                                  </div>
                                )}

                              <div className="flex items-center gap-1.5 mt-0.5">
                                <Badge
                                  variant="secondary"
                                  className="text-[10px] px-1 py-0 h-auto"
                                >
                                  {item.isUploading
                                    ? "uploading"
                                    : item.mediaType}
                                </Badge>
                                {(item.mediaType === "video" ||
                                  item.mediaType === "audio") &&
                                  item.durationInSeconds > 0 &&
                                  !item.isUploading && (
                                    <div className="flex items-center gap-0.5 text-[10px] text-muted-foreground">
                                      <Clock className="h-2.5 w-2.5" />
                                      {item.durationInSeconds.toFixed(1)}s
                                    </div>
                                  )}
                              </div>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}

            {counts.all === 0 && (
              <div className="flex flex-col items-center justify-center py-8 text-center">
                <FileImage className="h-8 w-8 text-muted-foreground/50 mb-3" />
                <p className="text-xs text-muted-foreground">No media files</p>
                <p className="text-xs text-muted-foreground/70 mt-0.5">
                  Import videos, images, or audio to get started
                </p>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Dropzone overlay */}
      {isDragOver && (
        <div className="absolute inset-0 z-50 bg-background/80">
          <div className="absolute inset-2 border-2 border-dashed border-primary/80 rounded-md flex items-center justify-center">
            <div className="pointer-events-none text-center">
              <Upload className="h-6 w-6 mx-auto mb-2 text-primary" />
              <p className="text-sm text-primary font-medium">
                Drop files to import
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Context Menu */}
      {contextMenu && (
        <div
          className="fixed bg-popover border border-border rounded-md shadow-lg z-50 py-1 min-w-32"
          style={{
            left: contextMenu.x,
            top: contextMenu.y,
          }}
          onClick={(e) => e.stopPropagation()}
        >
          <button
            className="w-full px-3 py-1.5 text-left text-xs hover:bg-accent hover:text-accent-foreground flex items-center gap-2"
            onClick={handleDeleteFromContext}
          >
            <Trash2 className="h-3 w-3" />
            Delete Media
          </button>
          {contextMenu.item.mediaType === "video" && (
            <button
              className="w-full px-3 py-1.5 text-left text-xs hover:bg-accent hover:text-accent-foreground flex items-center gap-2"
              onClick={handleSplitAudioFromContext}
            >
              <SplitSquareHorizontal className="h-3 w-3" />
              Split Audio
            </button>
          )}
        </div>
      )}

      {/* Preview overlay */}
      {previewItem && (
        <div
          ref={overlayRef}
          className="fixed inset-0 z-[60] bg-black/70"
          onClick={closePreview}
          onKeyDown={(e) => {
            if (e.key === "Escape") closePreview();
          }}
          tabIndex={-1}
          role="dialog"
          aria-modal="true"
        >
          <div className="w-full h-full flex items-center justify-center">
            <div
              className="w-full max-w-[760px] max-h-[80vh] border border-border rounded-md bg-popover shadow-lg flex flex-col overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between px-3 py-2 border-b border-border/50">
                <div className="flex items-center gap-2 min-w-0">
                  <Badge variant="secondary" className="text-[10px] h-4 px-1.5">
                    {previewItem.mediaType}
                  </Badge>
                  <p className="text-xs font-medium truncate pr-2">
                    {previewItem.name}
                  </p>
                </div>
                <Button
                  size="sm"
                  variant="ghost"
                  className="h-7 px-2 text-xs"
                  onClick={closePreview}
                >
                  Close
                </Button>
              </div>
              <div className="p-3 flex items-center justify-center overflow-auto">
                {previewItem.mediaType === "video" && (
                  <video
                    src={
                      previewItem.mediaUrlLocal ||
                      previewItem.mediaUrlRemote ||
                      undefined
                    }
                    controls
                    className="max-w-full max-h-[60vh] rounded"
                  />
                )}
                {previewItem.mediaType === "image" && (
                  <img
                    src={
                      previewItem.mediaUrlLocal ||
                      previewItem.mediaUrlRemote ||
                      undefined
                    }
                    alt={previewItem.name}
                    className="max-w-full max-h-[60vh] rounded object-contain border border-border/50"
                  />
                )}
                {previewItem.mediaType === "audio" && (
                  <AudioPreview
                    src={
                      previewItem.mediaUrlLocal ||
                      previewItem.mediaUrlRemote ||
                      ""
                    }
                  />
                )}
                {previewItem.mediaType === "text" && (
                  <div className="max-w-full max-h-[60vh] overflow-auto p-4 bg-card rounded border border-border/50">
                    <p className="text-sm whitespace-pre-wrap">
                      {previewItem.text?.textContent || previewItem.name}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}



================================================
FILE: app/components/timeline/MediaBinPage.tsx
================================================
import MediaBin from "./MediaBin";
import { useOutletContext } from "react-router";

export default function MediaBinPage() {
	// Pass through the existing Outlet context provided by the parent route
	// so MediaBin receives its props as in the index route.
	useOutletContext();
	return <MediaBin />;
}



================================================
FILE: app/components/timeline/MediaBinRoute.tsx
================================================
import MediaBin from "./MediaBin";
import { useOutletContext } from "react-router";

export default function MediaBinRoute() {
	const context = useOutletContext();
	// Simply reuse the index route component with the same context
	// This avoids duplicate route id while providing a concrete element for /editor/media-bin
	return <MediaBin />;
}



================================================
FILE: app/components/timeline/RenderActionButtons.tsx
================================================
import React from "react"

interface RenderActionButtonsProps {
  onRenderVideo: () => void
  onLogTimelineData: () => void
  isRendering: boolean
}

export const RenderActionButtons: React.FC<RenderActionButtonsProps> = ({
  onRenderVideo,
  onLogTimelineData,
  isRendering,
}) => {
  return (
    <div className="flex space-x-2">
      <button
        onClick={onRenderVideo}
        disabled={isRendering}
        className={`px-4 py-2 rounded border transition-colors cursor-pointer ${
          isRendering
            ? "bg-gray-600 border-gray-600 text-gray-400 cursor-not-allowed"
            : "bg-blue-600 border-blue-500 text-white hover:bg-blue-500"
        }`}
      >
        {isRendering ? "Rendering" : "Render"}
      </button>
      <button
        onClick={onLogTimelineData}
        className="px-4 py-2 bg-gray-700 border border-gray-600 text-gray-100 rounded hover:bg-gray-600 hover:border-blue-500 hover:text-white transition-colors cursor-pointer"
      >
        Stats
      </button>
    </div>
  )
} 


================================================
FILE: app/components/timeline/RenderStatus.tsx
================================================
import React from "react"

interface RenderStatusProps {
  renderStatus: string
}

export const RenderStatus: React.FC<RenderStatusProps> = ({ renderStatus }) => {
  if (!renderStatus) return null

  return (
    <div
      className={`p-3 rounded flex-shrink-0 text-sm ${
        renderStatus.startsWith("Error")
          ? "bg-red-900/50 text-red-300 border border-red-700"
          : renderStatus.includes("successfully")
          ? "bg-green-900/50 text-green-300 border border-green-700"
          : "bg-blue-900/50 text-blue-300 border border-blue-700"
      }`}
    >
      {renderStatus}
    </div>
  )
} 


================================================
FILE: app/components/timeline/Scrubber.tsx
================================================
import React, { useState, useRef, useCallback, useEffect } from "react";
import { DEFAULT_TRACK_HEIGHT, type ScrubberState, type Transition } from "./types";
import { Trash2, Group, Ungroup, Archive } from "lucide-react";

// something something for the css not gonna bother with it for now
export interface SnapConfig {
  enabled: boolean;
  distance: number; // snap distance in pixels
}

export interface ScrubberProps {
  scrubber: ScrubberState;
  timelineWidth: number;
  otherScrubbers: ScrubberState[];
  onUpdate: (updatedScrubber: ScrubberState) => void;
  onDelete?: (scrubberId: string) => void;
  containerRef: React.RefObject<HTMLDivElement | null>;
  expandTimeline: () => boolean;
  snapConfig: SnapConfig;
  trackCount: number;
  pixelsPerSecond: number;
  isSelected?: boolean;
  onSelect: (scrubberId: string, ctrlKey: boolean) => void;
  onGroupScrubbers: () => void;
  onUngroupScrubber: (scrubberId: string) => void;
  onMoveToMediaBin?: (scrubberId: string) => void;
  selectedScrubberIds: string[];
  onBeginTransform?: () => void; // drag or resize start snapshot
}

export const Scrubber: React.FC<ScrubberProps> = ({
  scrubber,
  timelineWidth,
  otherScrubbers,
  onUpdate,
  onDelete,
  containerRef,
  expandTimeline,
  snapConfig,
  trackCount,
  pixelsPerSecond,
  isSelected = false,
  onSelect,
  onGroupScrubbers,
  onUngroupScrubber,
  onMoveToMediaBin,
  selectedScrubberIds = [],
  onBeginTransform,
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [resizeMode, setResizeMode] = useState<"left" | "right" | null>(null);
  const dragStateRef = useRef({
    offsetX: 0,
    startX: 0,
    startLeft: 0,
    startWidth: 0,
  });
  const [contextMenu, setContextMenu] = useState<{
    visible: boolean;
    x: number;
    y: number;
  }>({ visible: false, x: 0, y: 0 });

  const MINIMUM_WIDTH = 20;

  // Get snap points (scrubber edges and grid marks)
  const getSnapPoints = useCallback(
    (excludeId?: string) => {
      const snapPoints: number[] = [];

      // Add grid marks based on current zoom level
      for (let pos = 0; pos <= timelineWidth; pos += pixelsPerSecond) {
        snapPoints.push(pos);
      }

      // Add scrubber edges
      otherScrubbers.forEach((other) => {
        if (other.id !== excludeId) {
          snapPoints.push(other.left);
          snapPoints.push(other.left + other.width);
        }
      });

      return snapPoints;
    },
    [otherScrubbers, timelineWidth, pixelsPerSecond]
  );

  // Find nearest snap point
  const findSnapPoint = useCallback(
    (position: number, excludeId?: string): number => {
      if (!snapConfig.enabled) return position;

      const snapPoints = getSnapPoints(excludeId);

      for (const snapPos of snapPoints) {
        if (Math.abs(position - snapPos) < snapConfig.distance) {
          return snapPos;
        }
      }

      return position;
    },
    [snapConfig, getSnapPoints]
  );



  const handleMouseDown = useCallback(
    (e: React.MouseEvent, mode: "drag" | "resize-left" | "resize-right") => {
      e.preventDefault();
      e.stopPropagation();

      // Select the scrubber when clicked
      if (onSelect) {
        onSelect(scrubber.id, e.ctrlKey);
      }

      // Prevent resizing for video and audio media
      if ((mode === "resize-left" || mode === "resize-right") && (scrubber.mediaType === "video" || scrubber.mediaType === "audio")) {
        return;
      }

      if (mode === "drag") {
        if (onBeginTransform) onBeginTransform();
        setIsDragging(true);
        dragStateRef.current.offsetX = e.clientX - scrubber.left;
      } else {
        if (onBeginTransform) onBeginTransform();
        setIsResizing(true);
        setResizeMode(mode === "resize-left" ? "left" : "right");
        dragStateRef.current.startX = e.clientX;
        dragStateRef.current.startLeft = scrubber.left;
        dragStateRef.current.startWidth = scrubber.width;
      }
    },
    [scrubber, onSelect, onBeginTransform]
  );

  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (!isDragging && !isResizing) return;
      // Remove throttling and requestAnimationFrame for responsive dragging
      if (isDragging) {
        let rawNewLeft = e.clientX - dragStateRef.current.offsetX;
        const min = 0;
        const max = timelineWidth - scrubber.width;
        rawNewLeft = Math.max(min, Math.min(max, rawNewLeft));

        // Calculate track changes based on mouse Y position with scroll offset
        let newTrack = scrubber.y || 0;
        if (containerRef.current) {
          const containerRect = containerRef.current.getBoundingClientRect();
          const scrollTop = containerRef.current.scrollTop || 0;
          const mouseY = e.clientY - containerRect.top + scrollTop;
          const trackIndex = Math.floor(mouseY / DEFAULT_TRACK_HEIGHT);
          newTrack = Math.max(0, Math.min(trackCount - 1, trackIndex));
        }

        // Apply snapping to the position
        const snappedLeft = findSnapPoint(rawNewLeft, scrubber.id);
        const updatedScrubber = { ...scrubber, left: snappedLeft, y: newTrack };

        // Let the timeline handle collision detection and connected scrubber logic
        onUpdate(updatedScrubber);

        // Auto-scroll when dragging near edges
        if (containerRef.current) {
          const scrollSpeed = 10;
          const scrollThreshold = 100;
          const containerRect = containerRef.current.getBoundingClientRect();
          const mouseX = e.clientX;

          if (mouseX < containerRect.left + scrollThreshold) {
            containerRef.current.scrollLeft -= scrollSpeed;
          } else if (mouseX > containerRect.right - scrollThreshold) {
            containerRef.current.scrollLeft += scrollSpeed;
            expandTimeline();
          }
        }
      } else if (isResizing) {
        const deltaX = e.clientX - dragStateRef.current.startX;

        if (resizeMode === "left") {
          let newLeft = dragStateRef.current.startLeft + deltaX;
          let newWidth = dragStateRef.current.startWidth - deltaX;

          if (scrubber.width === MINIMUM_WIDTH && deltaX > 0) {
            return;
          }

          newLeft = Math.max(0, newLeft);
          newWidth = Math.max(MINIMUM_WIDTH, newWidth);

          // Apply snapping to left edge
          newLeft = findSnapPoint(newLeft, scrubber.id);
          newWidth =
            dragStateRef.current.startLeft +
            dragStateRef.current.startWidth -
            newLeft;

          if (newLeft === 0) {
            newWidth =
              dragStateRef.current.startLeft +
              dragStateRef.current.startWidth;
          }

          if (newLeft + newWidth > timelineWidth) {
            newWidth = timelineWidth - newLeft;
          }

          const newScrubber = { ...scrubber, left: newLeft, width: newWidth };
          onUpdate(newScrubber);
        } else if (resizeMode === "right") {
          let newWidth = dragStateRef.current.startWidth + deltaX;

          newWidth = Math.max(MINIMUM_WIDTH, newWidth);

          // Apply snapping to right edge
          const rightEdge = dragStateRef.current.startLeft + newWidth;
          const snappedRightEdge = findSnapPoint(rightEdge, scrubber.id);
          newWidth = snappedRightEdge - dragStateRef.current.startLeft;

          if (dragStateRef.current.startLeft + newWidth > timelineWidth) {
            if (expandTimeline()) {
              // Recalculate after expansion
              const rightEdge =
                dragStateRef.current.startLeft +
                dragStateRef.current.startWidth +
                deltaX;
              const snappedRightEdge = findSnapPoint(rightEdge, scrubber.id);
              newWidth = snappedRightEdge - dragStateRef.current.startLeft;
            } else {
              newWidth = timelineWidth - dragStateRef.current.startLeft;
            }
          }

          const newScrubber = { ...scrubber, width: newWidth };
          onUpdate(newScrubber);
        }
      }
    },
    [
      isDragging,
      isResizing,
      resizeMode,
      scrubber,
      timelineWidth,
      onUpdate,
      expandTimeline,
      containerRef,
      findSnapPoint,
      trackCount,
    ]
  );

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
    setIsResizing(false);
    setResizeMode(null);
  }, []);

  useEffect(() => {
    document.addEventListener("mousemove", handleMouseMove);
    document.addEventListener("mouseup", handleMouseUp);

    return () => {
      document.removeEventListener("mousemove", handleMouseMove);
      document.removeEventListener("mouseup", handleMouseUp);
    };
  }, [handleMouseMove, handleMouseUp]);

  // Handle deletion with Delete/Backspace keys
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (isSelected && (e.key === "Delete" || e.key === "Backspace")) {
        // Prevent default behavior and check if we're not in an input field
        const target = e.target as HTMLElement;
        const isInputElement =
          target.tagName === "INPUT" ||
          target.tagName === "TEXTAREA" ||
          target.contentEditable === "true" ||
          target.isContentEditable;

        if (!isInputElement && onDelete) {
          e.preventDefault();
          onDelete(scrubber.id);
        }
      }
    };

    if (isSelected) {
      document.addEventListener("keydown", handleKeyDown);
      return () => document.removeEventListener("keydown", handleKeyDown);
    }
  }, [isSelected, onDelete, scrubber.id]);

  // Professional scrubber colors based on media type
  const getScrubberColor = () => {
    const baseColors = {
      video: "bg-primary border-primary/60 text-primary-foreground",
      image: "bg-green-600 border-green-500 text-white",
      text: "bg-purple-600 border-purple-500 text-white",
      default: "bg-primary border-primary/60 text-primary-foreground",
      audio: "bg-blue-600 border-blue-400 text-white",
      groupped_scrubber: "bg-gray-600 border-gray-400 text-white",
    };

    const selectedColors = {
      video:
        "bg-primary border-primary text-primary-foreground ring-2 ring-primary/50",
      image:
        "bg-green-600 border-green-400 text-white ring-2 ring-green-400/50",
      text: "bg-purple-600 border-purple-400 text-white ring-2 ring-purple-400/50",
      audio:
        "bg-blue-600 border-blue-400 text-white ring-2 ring-blue-400/50",
      default:
        "bg-primary border-primary text-primary-foreground ring-2 ring-primary/50",
      groupped_scrubber:
        "bg-gray-600 border-gray-400 text-white ring-2 ring-gray-400/50",
    };

    const colorSet = isSelected ? selectedColors : baseColors;
    return colorSet[scrubber.mediaType] || colorSet.default;
  };

  // Handle right-click context menu
  const handleContextMenu = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    // Select the scrubber when right-clicked
    if (onSelect) {
      onSelect(scrubber.id, e.ctrlKey);
    }

    // Get the position relative to the viewport
    setContextMenu({
      visible: true,
      x: e.clientX,
      y: e.clientY,
    });
  }, [onSelect, scrubber.id]);

  // Close context menu when clicking outside
  const handleClickOutside = useCallback((e: MouseEvent) => {
    if (contextMenu.visible) {
      setContextMenu({ visible: false, x: 0, y: 0 });
    }
  }, [contextMenu.visible]);

  // Handle context menu delete action
  const handleContextMenuDelete = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (onDelete) {
      onDelete(scrubber.id);
    }

    // Close context menu
    setContextMenu({ visible: false, x: 0, y: 0 });
  }, [onDelete, scrubber.id]);

  // Handle context menu group action
  const handleContextMenuGroup = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (onGroupScrubbers) {
      onGroupScrubbers();
    }

    // Close context menu
    setContextMenu({ visible: false, x: 0, y: 0 });
  }, [onGroupScrubbers]);

  // Handle context menu ungroup action
  const handleContextMenuUngroup = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (onUngroupScrubber) {
      onUngroupScrubber(scrubber.id);
    }

    // Close context menu
    setContextMenu({ visible: false, x: 0, y: 0 });
  }, [onUngroupScrubber, scrubber.id]);

  // Handle context menu move to media bin action
  const handleContextMenuMoveToMediaBin = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (onMoveToMediaBin) {
      onMoveToMediaBin(scrubber.id);
    }

    // Close context menu
    setContextMenu({ visible: false, x: 0, y: 0 });
  }, [onMoveToMediaBin, scrubber.id]);

  // Add click outside listener for context menu
  useEffect(() => {
    if (contextMenu.visible) {
      document.addEventListener("click", handleClickOutside);
      document.addEventListener("contextmenu", handleClickOutside);

      return () => {
        document.removeEventListener("click", handleClickOutside);
        document.removeEventListener("contextmenu", handleClickOutside);
      };
    }
  }, [contextMenu.visible, handleClickOutside]);

  return (
    <>
      <div
        className={`group absolute rounded-sm cursor-grab active:cursor-grabbing border shadow-sm hover:shadow-md transition-all ${getScrubberColor()} select-none`}
        style={{
          left: `${scrubber.left}px`,
          width: `${scrubber.width}px`,
          top: `${(scrubber.y || 0) * DEFAULT_TRACK_HEIGHT + 2}px`,
          height: `${DEFAULT_TRACK_HEIGHT - 4}px`,
          minWidth: "20px",
          zIndex: isDragging || isResizing ? 1000 : isSelected ? 20 : 15,
        }}
        onMouseDown={(e) => handleMouseDown(e, "drag")}
        onContextMenu={handleContextMenu}
      >
        {/* Media type indicator - positioned after left resize handle */}
        <div className="absolute top-0.5 left-3 text-xs font-medium opacity-80 pointer-events-none">
          {scrubber.mediaType === "video" && "V"}
          {scrubber.mediaType === "image" && "I"}
          {scrubber.mediaType === "text" && "T"}
          {scrubber.mediaType === "audio" && "A"}
          {scrubber.mediaType === "groupped_scrubber" && "G"}
        </div>

        {/* Media name */}
        <div className="absolute top-0.5 left-6 right-6 text-xs truncate opacity-90 pointer-events-none">
          {scrubber.name}
        </div>

        {/* Left resize handle - more visible */}
        {scrubber.mediaType !== "video" && scrubber.mediaType !== "audio" && scrubber.mediaType !== "groupped_scrubber" && (
          <div
            className="absolute top-0 left-0 h-full w-2 cursor-ew-resize z-20 hover:bg-white/30 transition-colors border-r border-white/20 group-hover:bg-white/10"
            onMouseDown={(e) => handleMouseDown(e, "resize-left")}
            title="Resize left edge"
          />
        )}

        {/* Right resize handle - more visible */}
        {scrubber.mediaType !== "video" && scrubber.mediaType !== "audio" && scrubber.mediaType !== "groupped_scrubber" && (
          <div
            className="absolute top-0 right-0 h-full w-2 cursor-ew-resize z-20 hover:bg-white/30 transition-colors border-l border-white/20 group-hover:bg-white/10"
            onMouseDown={(e) => handleMouseDown(e, "resize-right")}
            title="Resize right edge"
          />
        )}

        {/* Selection indicator - theme-appropriate glow effect */}
        {isSelected && (
          <div className="absolute -inset-0.5 rounded-sm pointer-events-none shadow-md shadow-primary/30 ring-1 ring-primary/60" />
        )}

        {/* Name and position tooltip when dragging - positioned above or below based on track */}
        {isDragging && (
          <div
            className={`absolute left-1/2 transform -translate-x-1/2 bg-popover text-popover-foreground text-xs px-2 py-1 rounded-sm pointer-events-none border border-border shadow-md z-50 whitespace-nowrap ${(scrubber.y || 0) === 0 ? "top-full mt-1" : "-top-8"
              }`}
          >
            {scrubber.name} • {(scrubber.left / pixelsPerSecond).toFixed(2)}s -{" "}
            {((scrubber.left + scrubber.width) / pixelsPerSecond).toFixed(2)}s
          </div>
        )}

        {/* Resize tooltips when resizing - showing precise timestamps with dynamic positioning */}
        {isResizing && (
          <div
            className={`absolute left-1/2 transform -translate-x-1/2 bg-popover text-popover-foreground text-xs px-2 py-1 rounded-sm pointer-events-none border border-border shadow-md z-50 whitespace-nowrap ${(scrubber.y || 0) === 0 ? "top-full mt-1" : "-top-8"
              }`}
          >
            {resizeMode === "left"
              ? `Start: ${(scrubber.left / pixelsPerSecond).toFixed(2)}s`
              : `End: ${(
                (scrubber.left + scrubber.width) /
                pixelsPerSecond
              ).toFixed(2)}s`}
          </div>
        )}
      </div>

      {/* Context Menu */}
      {contextMenu.visible && (
        <div
          className="fixed bg-popover text-popover-foreground border border-border rounded-md shadow-lg py-1 z-[9999]"
          style={{
            left: `${contextMenu.x}px`,
            top: `${contextMenu.y}px`,
          }}
        >
          {/* Show Group option if multiple scrubbers are selected but this isn't grouped */}
          {selectedScrubberIds.length > 1 && scrubber.mediaType !== "groupped_scrubber" && (
            <button
              className="flex items-center gap-2 w-full px-3 py-2 text-xs hover:bg-muted transition-colors text-left"
              onClick={handleContextMenuGroup}
            >
              <Group className="h-3 w-3" />
              Group Selected
            </button>
          )}

          {/* Show Ungroup option if this is a grouped scrubber */}
          {scrubber.mediaType === "groupped_scrubber" && (
            <button
              className="flex items-center gap-2 w-full px-3 py-2 text-xs hover:bg-muted transition-colors text-left"
              onClick={handleContextMenuUngroup}
            >
              <Ungroup className="h-3 w-3" />
              Ungroup
            </button>
          )}

          {/* Show Move to Media Bin option only for grouped scrubbers */}
          {scrubber.mediaType === "groupped_scrubber" && (
            <button
              className="flex items-center gap-2 w-full px-3 py-2 text-xs hover:bg-muted transition-colors text-left"
              onClick={handleContextMenuMoveToMediaBin}
            >
              <Archive className="h-3 w-3" />
              Move to Media Bin
            </button>
          )}

          <button
            className="flex items-center gap-2 w-full px-3 py-2 text-xs hover:bg-muted transition-colors text-left text-red-600 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300"
            onClick={handleContextMenuDelete}
          >
            <Trash2 className="h-3 w-3" />
            Delete
          </button>
        </div>
      )}
    </>
  );
};



================================================
FILE: app/components/timeline/TimelineControls.tsx
================================================
import React from "react"
import { TimelineTitle } from "./TimelineTitle"
import { DimensionControls } from "./DimensionControls"
import { MediaActionButtons } from "./MediaActionButtons"
import { TrackActionButton } from "./TrackActionButton"
import { RenderActionButtons } from "./RenderActionButtons"

interface TimelineControlsProps {
  onAddMedia: () => void
  onAddText: () => void
  onAddTrack: () => void
  onRenderVideo: () => void
  onLogTimelineData: () => void
  isRendering: boolean
  width: number
  height: number
  onWidthChange: (width: number) => void
  onHeightChange: (height: number) => void
  isAutoSize: boolean
  onAutoSizeChange: (auto: boolean) => void
}

export const TimelineControls: React.FC<TimelineControlsProps> = ({
  onAddMedia,
  onAddText,
  onAddTrack,
  onRenderVideo,
  onLogTimelineData,
  isRendering,
  width,
  height,
  onWidthChange,
  onHeightChange,
  isAutoSize,
  onAutoSizeChange,
}) => {
  return (
    <div className="flex justify-between items-center py-4 flex-shrink-0">
      <TimelineTitle />
      <div className="flex items-center space-x-4">
        {/* Aspect Ratio Controls */}
        <DimensionControls
          width={width}
          height={height}
          onWidthChange={onWidthChange}
          onHeightChange={onHeightChange}
          isAutoSize={isAutoSize}
          onAutoSizeChange={onAutoSizeChange}
        />
        
        {/* Action Buttons */}
        <div className="flex space-x-2">
          <MediaActionButtons
            onAddMedia={onAddMedia}
            onAddText={onAddText}
          />
          <TrackActionButton onAddTrack={onAddTrack} />
          <RenderActionButtons
            onRenderVideo={onRenderVideo}
            onLogTimelineData={onLogTimelineData}
            isRendering={isRendering}
          />
        </div>
      </div>
    </div>
  )
} 


================================================
FILE: app/components/timeline/TimelineRuler.tsx
================================================
import React, { useState, useEffect, useRef } from "react";
import { PIXELS_PER_SECOND, RULER_HEIGHT, FPS } from "./types";
import { Input } from "~/components/ui/input";

interface TimelineRulerProps {
  timelineWidth: number;
  rulerPositionPx: number;
  containerRef: React.RefObject<HTMLDivElement | null>;
  onRulerDrag: (newPositionPx: number) => void;
  onRulerMouseDown: (e: React.MouseEvent) => void;
  pixelsPerSecond: number;
  scrollLeft: number;
}

export const TimelineRuler: React.FC<TimelineRulerProps> = ({
  timelineWidth,
  rulerPositionPx,
  containerRef,
  onRulerDrag,
  onRulerMouseDown,
  pixelsPerSecond,
  scrollLeft,
}) => {
  const [isEditingTime, setIsEditingTime] = useState(false);
  const [timeInputValue, setTimeInputValue] = useState("");

  // Calculate current timestamp
  const currentTimeInSeconds = rulerPositionPx / pixelsPerSecond;
  const currentFrame = Math.round(currentTimeInSeconds * FPS);

  // Format timestamp to always show HH:MM:SS.mmm (matches professional NLEs)
  const formatTimestamp = (timeInSeconds: number) => {
    const totalMs = Math.max(0, Math.round(timeInSeconds * 1000));
    const hours = Math.floor(totalMs / 3600000);
    const minutes = Math.floor((totalMs % 3600000) / 60000);
    const seconds = Math.floor((totalMs % 60000) / 1000);
    const milliseconds = totalMs % 1000;

    return `${hours.toString().padStart(2, "0")}:${minutes
      .toString()
      .padStart(2, "0")}:${seconds.toString().padStart(2, "0")}.${milliseconds.toString().padStart(3, "0")}`;
  };

  // Format ruler marks to mm:ss or HH:MM:SS, centered on major ticks
  const formatRulerMark = (timeInSeconds: number) => {
    const totalSeconds = Math.max(0, Math.floor(timeInSeconds));
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, "0")}:${minutes
        .toString()
        .padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
    }
    return `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
  };

  // Handle time input submission with improved parsing
  const handleTimeInputSubmit = () => {
    const timeString = timeInputValue.trim();
    if (!timeString) {
      setIsEditingTime(false);
      return;
    }

    // Parse various time formats (mm:ss.ms, ss.ms, ss, frames, etc.)
    let totalSeconds = 0;
    try {
      if (timeString.includes(":")) {
        // Format: mm:ss.ms or mm:ss
        const [minutes, secondsAndMs] = timeString.split(":");
        if (secondsAndMs.includes(".")) {
          const [seconds, ms] = secondsAndMs.split(".");
          totalSeconds = parseInt(minutes) * 60 + parseInt(seconds) + parseFloat(`0.${ms}`);
        } else {
          totalSeconds = parseInt(minutes) * 60 + parseInt(secondsAndMs);
        }
      } else if (timeString.includes(".")) {
        // Format: ss.ms
        totalSeconds = parseFloat(timeString);
      } else if (timeString.endsWith("f") || timeString.endsWith("F")) {
        // Format: frame number (e.g., "120f" for frame 120)
        const frameNum = parseInt(timeString.slice(0, -1));
        totalSeconds = frameNum / FPS;
      } else {
        // Plain number, treat as seconds
        totalSeconds = parseFloat(timeString);
      }

      const newPositionPx = totalSeconds * pixelsPerSecond;
      onRulerDrag(Math.max(0, Math.min(newPositionPx, timelineWidth)));
    } catch (error) {
      console.warn("Invalid time format:", timeString);
    }

    setIsEditingTime(false);
    setTimeInputValue("");
  };

  const handleTimeInputKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      handleTimeInputSubmit();
    } else if (e.key === "Escape") {
      setIsEditingTime(false);
      setTimeInputValue("");
    }
  };

  // Fixed professional cadence (adaptive to zoom):
  // - Major ticks adapt between 10s → 5s → 1s based on zoom
  // - Mid-major 5s (only when majors are 10s)
  // - Minor 1s
  // - Micro 0.5s, 0.25s, 0.1s depending on zoom
  // - Frame-level ticks when extremely zoomed in
  const majorSeconds = pixelsPerSecond >= 500 ? 1 : pixelsPerSecond >= 180 ? 5 : 10;
  const MID_MAJOR_SECONDS = 5;
  const MINOR_SECONDS = 1;
  const MICRO_SECONDS = 0.5;
  const MICRO_QUARTER_SECONDS = 0.25;
  const MICRO_TENTH_SECONDS = 0.1;
  const FRAME_SECONDS = 1 / FPS;

  // Visibility thresholds (slightly lowered to show more markings)
  const showMidMajor = majorSeconds === 10 && pixelsPerSecond * MID_MAJOR_SECONDS >= 64;
  const showMinor = pixelsPerSecond * MINOR_SECONDS >= 6; // 1s ticks earlier
  const showMinorLabels = pixelsPerSecond >= 120; // show 1s labels when sufficiently zoomed
  // To reduce clutter at high zoom, require bigger thresholds for denser ticks
  const showMicro = pixelsPerSecond * MICRO_SECONDS >= 6; // 0.5s
  const showMicroQuarter = pixelsPerSecond * MICRO_QUARTER_SECONDS >= 10; // 0.25s
  const showMicroTenth = pixelsPerSecond * MICRO_TENTH_SECONDS >= 14; // 0.1s
  const showFrames = pixelsPerSecond * FRAME_SECONDS >= 18; // frame ticks
  const showFrameLabelsEvery = 10; // label every Nth frame to avoid clutter

  const formatMajorLabel = (seconds: number) => {
    const total = Math.floor(seconds);
    const mm = Math.floor((total % 3600) / 60)
      .toString()
      .padStart(2, "0");
    const ss = (total % 60).toString().padStart(2, "0");
    return `${mm}:${ss}`;
  };
  const formatSubSecondLabel = (time: number, step: number) => {
    const totalMs = Math.round(time * 1000);
    const totalSeconds = Math.floor(totalMs / 1000);
    const mm = Math.floor((totalSeconds % 3600) / 60)
      .toString()
      .padStart(2, "0");
    const ss = (totalSeconds % 60).toString().padStart(2, "0");
    const ms = totalMs % 1000;
    // Decide decimals based on step granularity
    if (step >= 0.5) {
      // show 1 decimal (tenths)
      const tenths = Math.round(ms / 100);
      return `${mm}:${ss}.${tenths}`;
    }
    if (step >= 0.25) {
      // show 2 decimals
      const hundredths = Math.round(ms / 10)
        .toString()
        .padStart(2, "0");
      return `${mm}:${ss}.${hundredths}`;
    }
    // 0.1s → 1 decimal is fine; but if even finer, fall back to 3 decimals
    if (step >= 0.1) {
      const tenths = Math.round(ms / 100);
      return `${mm}:${ss}.${tenths}`;
    }
    return `${mm}:${ss}.${ms.toString().padStart(3, "0")}`;
  };
  const formatFrameLabel = (time: number) => {
    const totalFrames = Math.round(time * FPS);
    const seconds = Math.floor(totalFrames / FPS);
    const frames = totalFrames % FPS;
    const mm = Math.floor((seconds % 3600) / 60)
      .toString()
      .padStart(2, "0");
    const ss = (seconds % 60).toString().padStart(2, "0");
    const ff = frames.toString().padStart(2, "0");
    return `${mm}:${ss}:${ff}`;
  };
  return (
    <div className="flex flex-shrink-0 h-6 border-b border-border/30">
      {/* Track controls header with timestamp display */}
      <div className="w-28 bg-muted/70 border-r border-border/50 flex-shrink-0 flex flex-col items-center justify-center py-1 px-2">
        {isEditingTime ? (
          <Input
            value={timeInputValue}
            onChange={(e) => setTimeInputValue(e.target.value)}
            onBlur={handleTimeInputSubmit}
            onKeyDown={handleTimeInputKeyDown}
            placeholder="00:00:00.000"
            className="h-3 text-xs font-mono w-full px-1 py-0 text-center border-0 bg-transparent focus:bg-muted/50 transition-colors"
            autoFocus
          />
        ) : (
          <div
            className="w-full text-xs font-mono text-foreground font-medium leading-none cursor-pointer hover:bg-muted/50 px-1 py-0.5 rounded transition-colors whitespace-nowrap overflow-hidden text-center"
            onClick={() => {
              setIsEditingTime(true);
              setTimeInputValue(formatTimestamp(currentTimeInSeconds));
            }}
            title="Click to edit time (supports mm:ss.ms, ss.ms, 120f formats)">
            {formatTimestamp(currentTimeInSeconds)}
          </div>
        )}
      </div>

      {/* Timeline Ruler */}
      <div
        className="bg-gradient-to-b from-muted/60 to-muted/40 cursor-pointer relative z-20 flex-1 overflow-hidden"
        style={{ height: "24px" }}>
        <div
          className="absolute top-0 left-0 h-full"
          style={{
            width: `${timelineWidth}px`,
            transform: `translateX(-${scrollLeft}px)`,
          }}
          onClick={(e) => {
            if (containerRef.current) {
              // e.currentTarget is the ruler content div that's already positioned with transform
              // The click position relative to this div is already the correct timeline position
              const rulerRect = e.currentTarget.getBoundingClientRect();
              const clickXInRuler = e.clientX - rulerRect.left;

              // Since the ruler content is already transformed to account for scroll,
              // clickXInRuler is already the correct absolute position in the timeline
              onRulerDrag(clickXInRuler);
            }
          }}>
          {/* Major markings - adaptive with labels (no 00:00) */}
          {(() => {
            const elements: React.ReactNode[] = [];
            let lastLabelX = -Infinity;
            const minLabelSpacingPx = 40; // avoid label overlap
            const count = Math.floor(timelineWidth / (majorSeconds * pixelsPerSecond)) + 1;
            for (let tick = 0; tick < count; tick++) {
              const timeValue = tick * majorSeconds;
              const x = tick * majorSeconds * pixelsPerSecond;
              const showLabel = timeValue !== 0 && x - lastLabelX >= minLabelSpacingPx;
              if (showLabel) {
                lastLabelX = x;
              }
              elements.push(
                <div
                  key={`major-mark-${tick}`}
                  className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                  style={{ left: `${x}px` }}>
                  {showLabel ? (
                    <span className="text-[9px] text-muted-foreground -translate-x-1/2 mt-0.5 bg-background/90 px-1 py-0.5 rounded-sm border border-border/30 font-mono leading-none">
                      {formatMajorLabel(timeValue)}
                    </span>
                  ) : (
                    <span className="sr-only">{formatMajorLabel(timeValue)}</span>
                  )}
                  <div className="w-px bg-border h-4 mt-auto" />
                </div>,
              );
            }
            return elements;
          })()}

          {/* Mid-major 5s ticks with small label when dense */}
          {showMidMajor &&
            (() => {
              const elements: React.ReactNode[] = [];
              const count = Math.floor(timelineWidth / (MID_MAJOR_SECONDS * pixelsPerSecond)) + 1;
              for (let tick = 1; tick < count; tick++) {
                const timeValue = tick * MID_MAJOR_SECONDS;
                // skip those that coincide with major ticks
                if (timeValue % majorSeconds === 0) continue;
                const x = tick * MID_MAJOR_SECONDS * pixelsPerSecond;
                elements.push(
                  <div
                    key={`mid-major-${tick}`}
                    className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                    style={{ left: `${x}px` }}>
                    <span className="text-[8px] text-muted-foreground/80 -translate-x-1/2 mt-0.5 bg-background/80 px-1 py-0.5 rounded-sm border border-border/20 font-mono leading-none">
                      {formatMajorLabel(timeValue)}
                    </span>
                    <div className="w-px bg-border/80 h-3 mt-auto" />
                  </div>,
                );
              }
              return elements;
            })()}

          {/* Minor markings - 1s ticks with optional labels at high zoom */}
          {showMinor &&
            (() => {
              const elements: React.ReactNode[] = [];
              let lastLabelX = -Infinity;
              const minLabelSpacingPx = 36;
              const count = Math.floor(timelineWidth / (MINOR_SECONDS * pixelsPerSecond)) + 1;
              for (let tick = 0; tick < count; tick++) {
                const timeValue = tick * MINOR_SECONDS;
                const isMajorTick = timeValue % majorSeconds === 0;
                if (isMajorTick) continue;
                const x = tick * MINOR_SECONDS * pixelsPerSecond;
                const canShowLabel = showMinorLabels && x - lastLabelX >= minLabelSpacingPx;
                if (canShowLabel) lastLabelX = x;
                elements.push(
                  <div
                    key={`minor-mark-${tick}`}
                    className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                    style={{ left: `${x}px` }}>
                    {showMinorLabels && canShowLabel ? (
                      <span className="text-[8px] text-muted-foreground/80 -translate-x-1/2 mt-0.5 bg-background/80 px-1 py-0.5 rounded-sm border border-border/20 font-mono leading-none">
                        {formatSubSecondLabel(timeValue, MINOR_SECONDS)}
                      </span>
                    ) : (
                      <span className="sr-only">{formatSubSecondLabel(timeValue, MINOR_SECONDS)}</span>
                    )}
                    <div className="w-px bg-border/60 h-3 mt-auto" />
                  </div>,
                );
              }
              return elements;
            })()}

          {/* Micro markings - 0.5s ticks */}
          {showMicro &&
            Array.from(
              {
                length: Math.floor(timelineWidth / (MICRO_SECONDS * pixelsPerSecond)) + 1,
              },
              (_, index) => index,
            ).map((tick) => {
              const timeValue = tick * MICRO_SECONDS;
              const isMinorTick = timeValue % MINOR_SECONDS === 0;
              const isMajorTick = timeValue % majorSeconds === 0;
              if (isMinorTick || isMajorTick) return null;
              const x = tick * MICRO_SECONDS * pixelsPerSecond;
              const showLabel = pixelsPerSecond * MICRO_SECONDS >= 140; // label at very high zoom
              return (
                <div
                  key={`micro-mark-${tick}`}
                  className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                  style={{ left: `${x}px` }}>
                  {showLabel ? (
                    <span className="text-[8px] text-muted-foreground/70 -translate-x-1/2 mt-0.5 bg-background/70 px-1 py-0.5 rounded-sm border border-border/20 font-mono leading-none">
                      {formatSubSecondLabel(timeValue, MICRO_SECONDS)}
                    </span>
                  ) : (
                    <span className="sr-only">{formatSubSecondLabel(timeValue, MICRO_SECONDS)}</span>
                  )}
                  <div className="w-px bg-border/30 h-2 mt-auto" />
                </div>
              );
            })}

          {/* Micro 0.25s ticks */}
          {showMicroQuarter &&
            Array.from(
              {
                length: Math.floor(timelineWidth / (MICRO_QUARTER_SECONDS * pixelsPerSecond)) + 1,
              },
              (_, index) => index,
            ).map((tick) => {
              const timeValue = tick * MICRO_QUARTER_SECONDS;
              const isHigherTick =
                timeValue % MICRO_SECONDS === 0 || timeValue % MINOR_SECONDS === 0 || timeValue % majorSeconds === 0;
              if (isHigherTick) return null;
              const x = tick * MICRO_QUARTER_SECONDS * pixelsPerSecond;
              const showLabel = pixelsPerSecond * MICRO_QUARTER_SECONDS >= 160;
              return (
                <div
                  key={`micro-quarter-${tick}`}
                  className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                  style={{ left: `${x}px` }}>
                  {showLabel ? (
                    <span className="text-[7px] text-muted-foreground/70 -translate-x-1/2 mt-0.5 bg-background/60 px-1 py-[1px] rounded-sm border border-border/20 font-mono leading-none">
                      {formatSubSecondLabel(timeValue, MICRO_QUARTER_SECONDS)}
                    </span>
                  ) : (
                    <span className="sr-only">{formatSubSecondLabel(timeValue, MICRO_QUARTER_SECONDS)}</span>
                  )}
                  <div className="w-px bg-border/20 h-1.5 mt-auto" />
                </div>
              );
            })}

          {/* Micro 0.1s ticks */}
          {showMicroTenth &&
            Array.from(
              {
                length: Math.floor(timelineWidth / (MICRO_TENTH_SECONDS * pixelsPerSecond)) + 1,
              },
              (_, index) => index,
            ).map((tick) => {
              const timeValue = tick * MICRO_TENTH_SECONDS;
              const isHigherTick =
                timeValue % MICRO_QUARTER_SECONDS === 0 ||
                timeValue % MICRO_SECONDS === 0 ||
                timeValue % MINOR_SECONDS === 0 ||
                timeValue % majorSeconds === 0;
              if (isHigherTick) return null;
              const x = tick * MICRO_TENTH_SECONDS * pixelsPerSecond;
              const showLabel = pixelsPerSecond * MICRO_TENTH_SECONDS >= 200;
              return (
                <div
                  key={`micro-tenth-${tick}`}
                  className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                  style={{ left: `${x}px` }}>
                  {showLabel ? (
                    <span className="text-[7px] text-muted-foreground/60 -translate-x-1/2 mt-0.5 bg-background/50 px-1 py-[1px] rounded-sm border border-border/20 font-mono leading-none">
                      {formatSubSecondLabel(timeValue, MICRO_TENTH_SECONDS)}
                    </span>
                  ) : (
                    <span className="sr-only">{formatSubSecondLabel(timeValue, MICRO_TENTH_SECONDS)}</span>
                  )}
                  <div className="w-px bg-border/10 h-1 mt-auto" />
                </div>
              );
            })}

          {/* Frame-level ticks at extreme zoom */}
          {showFrames &&
            Array.from(
              {
                length: Math.floor(timelineWidth / (FRAME_SECONDS * pixelsPerSecond)) + 1,
              },
              (_, index) => index,
            ).map((tick) => {
              const timeValue = tick * FRAME_SECONDS;
              const isHigherTick =
                timeValue % MICRO_TENTH_SECONDS === 0 ||
                timeValue % MICRO_QUARTER_SECONDS === 0 ||
                timeValue % MICRO_SECONDS === 0 ||
                timeValue % MINOR_SECONDS === 0 ||
                timeValue % majorSeconds === 0;
              if (isHigherTick) return null;
              const x = tick * FRAME_SECONDS * pixelsPerSecond;
              const labelThis = tick % showFrameLabelsEvery === 0 && pixelsPerSecond * FRAME_SECONDS >= 16;
              return (
                <div
                  key={`frame-${tick}`}
                  className="absolute top-0 h-full flex flex-col justify-between pointer-events-none"
                  style={{ left: `${x}px` }}>
                  {labelThis ? (
                    <span className="text-[7px] text-muted-foreground/60 -translate-x-1/2 mt-0.5 bg-background/40 px-1 py-[1px] rounded-sm border border-border/10 font-mono leading-none">
                      {formatFrameLabel(timeValue)}
                    </span>
                  ) : (
                    <span className="sr-only">{formatFrameLabel(timeValue)}</span>
                  )}
                  <div className="w-px bg-border/10 h-0.5 mt-auto" />
                </div>
              );
            })}

          {/* Playhead line - contained within ruler */}
          <div
            className="absolute top-0 w-0.5 bg-primary pointer-events-none z-30 shadow-sm"
            style={{
              left: `${rulerPositionPx}px`,
              height: "24px",
            }}
          />

          {/* Playhead handle - compact design */}
          <div
            className="absolute bg-primary cursor-grab hover:cursor-grabbing z-30 border border-background shadow-lg hover:shadow-xl transition-shadow"
            style={{
              left: `${rulerPositionPx - 4}px`,
              top: "2px",
              width: "8px",
              height: "8px",
              borderRadius: "1px",
              transform: "none",
              transition: "box-shadow 0.15s ease",
            }}
            onMouseDown={onRulerMouseDown}
            title="Drag to seek"
          />
        </div>
      </div>
    </div>
  );
};



================================================
FILE: app/components/timeline/TimelineTitle.tsx
================================================
import React from "react"

export const TimelineTitle: React.FC = () => {
  return <h2 className="text-2xl font-bold">Timeline</h2>
} 


================================================
FILE: app/components/timeline/TimelineTracks.tsx
================================================
import React, { useEffect, useState } from "react";
import { Trash2 } from "lucide-react";
import { Button } from "~/components/ui/button";
import { ScrollArea } from "~/components/ui/scroll-area";
import { Scrubber } from "./Scrubber";
import { TransitionOverlay } from "./TransitionOverlay";
import {
  DEFAULT_TRACK_HEIGHT,
  PIXELS_PER_SECOND,
  type ScrubberState,
  type MediaBinItem,
  type TimelineState,
  type Transition,
} from "./types";

interface TimelineTracksProps {
  timeline: TimelineState;
  timelineWidth: number;
  rulerPositionPx: number;
  containerRef: React.RefObject<HTMLDivElement | null>;
  onScroll: () => void;
  onDeleteTrack: (trackId: string) => void;
  onUpdateScrubber: (updatedScrubber: ScrubberState) => void;
  onDeleteScrubber?: (scrubberId: string) => void;
  onBeginScrubberTransform?: () => void;
  onDropOnTrack: (
    item: MediaBinItem,
    trackId: string,
    dropLeftPx: number
  ) => void;
  onDropTransitionOnTrack: (
    transition: Transition,
    trackId: string,
    dropLeftPx: number
  ) => void;
  onDeleteTransition: (transitionId: string) => void;
  getAllScrubbers: () => ScrubberState[];
  expandTimeline: () => boolean;
  onRulerMouseDown: (e: React.MouseEvent) => void;
  pixelsPerSecond: number;
  selectedScrubberIds: string[];
  onSelectScrubber: (scrubberId: string | null, ctrlKey: boolean) => void;
  onGroupScrubbers: () => void;
  onUngroupScrubber: (scrubberId: string) => void;
  onMoveToMediaBin?: (scrubberId: string) => void;
}

export const TimelineTracks: React.FC<TimelineTracksProps> = ({
  timeline,
  timelineWidth,
  rulerPositionPx,
  containerRef,
  onScroll,
  onDeleteTrack,
  onUpdateScrubber,
  onDeleteScrubber,
  onBeginScrubberTransform,
  onDropOnTrack,
  onDropTransitionOnTrack,
  onDeleteTransition,
  getAllScrubbers,
  expandTimeline,
  onRulerMouseDown,
  pixelsPerSecond,
  selectedScrubberIds,
  onSelectScrubber,
  onGroupScrubbers,
  onUngroupScrubber,
  onMoveToMediaBin,
}) => {
  const [scrollTop, setScrollTop] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);

  // Sync track controls with timeline scroll
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const handleScroll = () => {
      setScrollTop(container.scrollTop);
      setScrollLeft(container.scrollLeft);
      onScroll();
    };

    container.addEventListener("scroll", handleScroll);
    return () => container.removeEventListener("scroll", handleScroll);
  }, [onScroll, containerRef]);

  // Global click handler to deselect when clicking outside timeline
  useEffect(() => {
    const handleGlobalClick = (e: MouseEvent) => {
      const timelineContainer = containerRef.current;
      if (timelineContainer && !timelineContainer.contains(e.target as Node)) {
        onSelectScrubber(null, false);
      }
    };

    if (selectedScrubberIds.length > 0) {
      document.addEventListener("click", handleGlobalClick);
      return () => document.removeEventListener("click", handleGlobalClick);
    }
  }, [selectedScrubberIds, containerRef, onSelectScrubber]);

  return (
    <div className="flex flex-1 min-h-0">
      {/* Track controls column - scrolls with tracks */}
      <div className="w-28 bg-muted border-r border-border/50 flex-shrink-0 overflow-hidden">
        <div
          className="flex flex-col"
          style={{
            transform: `translateY(-${containerRef.current?.scrollTop || 0}px)`,
            height: `${timeline.tracks.length * DEFAULT_TRACK_HEIGHT}px`,
          }}
        >
          {timeline.tracks.map((track, index) => (
            <div
              key={`control-${track.id}`}
              className="flex items-center justify-start gap-2 px-2 border-b border-border/30 bg-muted/30 relative"
              style={{ height: `${DEFAULT_TRACK_HEIGHT}px` }}
            >
              <Button
                variant="ghost"
                size="sm"
                onClick={() => onDeleteTrack(track.id)}
                className="h-6 w-6 p-0 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-sm"
                title={`Delete Track ${index + 1}`}
                aria-label={`Delete Track ${index + 1}`}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
              <span className="text-xs text-foreground font-medium select-none">Track {index + 1}</span>
              {/* Track indicator line */}
              <div className="absolute right-0 top-0 bottom-0 w-px bg-border/50" />
            </div>
          ))}
        </div>
      </div>

      {/* Scrollable Tracks Area */}
      <div
        ref={containerRef}
        className={`relative flex-1 bg-timeline-background timeline-scrollbar ${timeline.tracks.length === 0 ? "overflow-hidden" : "overflow-auto"
          }`}
        onScroll={timeline.tracks.length > 0 ? onScroll : undefined}
      >
        {timeline.tracks.length === 0 ? (
          /* Empty state - non-scrollable and centered */
          <div className="h-full flex items-center justify-center text-muted-foreground">
            <p className="text-sm">No tracks. Click "Track" to get started.</p>
          </div>
        ) : (
          <>
            {/* Playhead Line */}
            <div
              className="absolute top-0 w-0.5 bg-primary pointer-events-none z-40"
              style={{
                left: `${rulerPositionPx}px`,
                height: `${Math.max(
                  timeline.tracks.length * DEFAULT_TRACK_HEIGHT,
                  200
                )}px`,
              }}
            />

            {/* Tracks Content */}
            <div
              className="bg-timeline-background relative"
              style={{
                width: `${timelineWidth}px`,
                height: `${timeline.tracks.length * DEFAULT_TRACK_HEIGHT}px`,
                minHeight: "100%",
              }}
              onDragOver={(e) => e.preventDefault()}
              onClick={(e) => {
                // Deselect scrubber when clicking on empty timeline area
                if (e.target === e.currentTarget) {
                  onSelectScrubber(null, false);
                }
              }}
              onDrop={(e) => {
                e.preventDefault();

                const jsonString = e.dataTransfer.getData("application/json");
                if (!jsonString) return;

                const data = JSON.parse(jsonString);

                // Use containerRef for consistent coordinate calculation like the ruler does
                const scrollContainer = containerRef.current;
                if (!scrollContainer) return;

                const containerBounds = scrollContainer.getBoundingClientRect();
                const scrollLeft = scrollContainer.scrollLeft || 0;
                const scrollTop = scrollContainer.scrollTop || 0;

                // Calculate drop position relative to the scroll container, accounting for scroll
                const dropXInTimeline = e.clientX - containerBounds.left + scrollLeft;
                const dropYInTimeline = e.clientY - containerBounds.top + scrollTop;

                let trackIndex = Math.floor(
                  dropYInTimeline / DEFAULT_TRACK_HEIGHT
                );
                trackIndex = Math.max(
                  0,
                  Math.min(timeline.tracks.length - 1, trackIndex)
                );

                const trackId = timeline.tracks[trackIndex]?.id;

                if (!trackId) {
                  console.warn("No tracks to drop on, or track detection failed.");
                  return;
                }

                // Handle transition drop
                if (data.type === "transition") {
                  onDropTransitionOnTrack(data, trackId, dropXInTimeline);
                } else {
                  // Handle media item drop
                  onDropOnTrack(data as MediaBinItem, trackId, dropXInTimeline);
                }
              }}
            >
              {/* Track backgrounds and grid lines */}
              {timeline.tracks.map((track, trackIndex) => (
                <div
                  key={track.id}
                  className="relative"
                  style={{ height: `${DEFAULT_TRACK_HEIGHT}px` }}
                >
                  {/* Track background */}
                  <div
                    className={`absolute w-full border-b border-border/30 transition-colors ${trackIndex % 2 === 0
                      ? "bg-timeline-track hover:bg-timeline-track/80"
                      : "bg-timeline-background hover:bg-muted/20"
                      }`}
                    style={{
                      top: `0px`,
                      height: `${DEFAULT_TRACK_HEIGHT}px`,
                    }}
                    onClick={(e) => {
                      // Deselect scrubber when clicking on track background
                      if (e.target === e.currentTarget) {
                        onSelectScrubber(null, false);
                      }
                    }}
                  />

                  {/* Track label - positioned behind scrubbers
                  <div
                    className="absolute left-2 top-1 text-xs text-muted-foreground font-medium pointer-events-none select-none z-[5]"
                    style={{ userSelect: "none" }}
                  >
                    Track {trackIndex + 1}
                  </div> */}

                  {/* Grid lines */}
                  {Array.from(
                    { length: Math.floor(timelineWidth / pixelsPerSecond) + 1 },
                    (_, index) => index
                  ).map((gridIndex) => (
                    <div
                      key={`grid-${track.id}-${gridIndex}`}
                      className="absolute h-full pointer-events-none"
                      style={{
                        left: `${gridIndex * pixelsPerSecond}px`,
                        top: `0px`,
                        width: "1px",
                        height: `${DEFAULT_TRACK_HEIGHT}px`,
                        backgroundColor: `rgb(var(--border) / ${gridIndex % 5 === 0 ? 0.5 : 0.25
                          })`,
                      }}
                    />
                  ))}
                </div>
              ))}

              {/* Scrubbers */}
              {getAllScrubbers().map((scrubber) => {
                // Get all transitions for the track containing this scrubber
                const scrubberTrack = timeline.tracks.find(track =>
                  track.scrubbers.some(s => s.id === scrubber.id)
                );

                return (
                  <Scrubber
                    key={scrubber.id}
                    scrubber={scrubber}
                    timelineWidth={timelineWidth}
                    otherScrubbers={getAllScrubbers().filter(
                      (s) => s.id !== scrubber.id
                    )}
                    onUpdate={onUpdateScrubber}
                    onDelete={onDeleteScrubber}
                    isSelected={selectedScrubberIds.includes(scrubber.id)}
                    onSelect={onSelectScrubber}
                    onGroupScrubbers={onGroupScrubbers}
                    onUngroupScrubber={onUngroupScrubber}
                    onMoveToMediaBin={onMoveToMediaBin}
                    selectedScrubberIds={selectedScrubberIds}
                    containerRef={containerRef}
                    expandTimeline={expandTimeline}
                    snapConfig={{ enabled: true, distance: 10 }}
                    trackCount={timeline.tracks.length}
                    pixelsPerSecond={pixelsPerSecond}
                    onBeginTransform={onBeginScrubberTransform}
                  />
                );
              })}

              {/* Transitions */}
              {(() => {
                const transitionComponents = [];
                // Get all scrubbers across all tracks for transition lookup
                const allScrubbers = getAllScrubbers();
                
                for (const track of timeline.tracks) {
                  for (const transition of track.transitions) {
                    const leftScrubber = transition.leftScrubberId ?
                      allScrubbers.find(s => s.id === transition.leftScrubberId) || null : null;
                    const rightScrubber = transition.rightScrubberId ?
                      allScrubbers.find(s => s.id === transition.rightScrubberId) || null : null;

                    if (leftScrubber == null && rightScrubber == null) {
                      continue;
                    }

                    transitionComponents.push(
                      <TransitionOverlay
                        key={transition.id}
                        transition={transition}
                        leftScrubber={leftScrubber}
                        rightScrubber={rightScrubber}
                        pixelsPerSecond={pixelsPerSecond}
                        onDelete={onDeleteTransition}
                      />
                    );
                  }
                }
                return transitionComponents;
              })()}
            </div>
          </>
        )}
      </div>
    </div>
  );
};



================================================
FILE: app/components/timeline/TrackActionButton.tsx
================================================
import React from "react"

interface TrackActionButtonProps {
  onAddTrack: () => void
}

export const TrackActionButton: React.FC<TrackActionButtonProps> = ({
  onAddTrack,
}) => {
  return (
    <button
      onClick={onAddTrack}
      className="px-4 py-2 bg-gray-700 border border-gray-600 text-gray-100 rounded hover:bg-gray-600 hover:border-blue-500 hover:text-white transition-colors cursor-pointer"
    >
      Track
    </button>
  )
} 


================================================
FILE: app/components/timeline/TransitionOverlay.tsx
================================================
import React, { useState } from "react";
import { X } from "lucide-react";
import { Button } from "~/components/ui/button";
import { type Transition, type ScrubberState, DEFAULT_TRACK_HEIGHT } from "./types";

interface TransitionOverlayProps {
  transition: Transition;
  leftScrubber: ScrubberState | null;
  rightScrubber: ScrubberState | null;
  pixelsPerSecond: number;
  onDelete: (transitionId: string) => void;
}

export const TransitionOverlay: React.FC<TransitionOverlayProps> = ({
  transition,
  leftScrubber,
  rightScrubber,
  pixelsPerSecond,
  onDelete,
}) => {
  const [isHovered, setIsHovered] = useState(false);
  // console.log("transition hovered", isHovered);


  // Calculate position and size for overlap area
  const getTransitionStyle = () => {
    let left = 0;
    const width = (transition.durationInFrames / 30) * pixelsPerSecond; // Convert frames to pixels
    let top = 0;
    
    // Define snap distance threshold (same as in useTimeline.ts)
    const SNAP_DISTANCE = 10;

    if (leftScrubber && rightScrubber) {
      // Check if there's an overlap or a gap between scrubbers
      const leftScrubberEnd = leftScrubber.left + leftScrubber.width;
      const gap = rightScrubber.left - leftScrubberEnd;
      
      if (gap <= SNAP_DISTANCE) {
        // Scrubbers are close enough - position transition on the overlap area
        // The overlap starts at the rightScrubber.left and has width equal to transition duration
        const overlapStart = rightScrubber.left;
        left = overlapStart;
        top = leftScrubber.y * DEFAULT_TRACK_HEIGHT;
      } else {
        // There's a gap - position the transition as an outro from the left scrubber
        left = leftScrubber.left + leftScrubber.width - width;
        top = leftScrubber.y * DEFAULT_TRACK_HEIGHT;
      }
    } else if (leftScrubber) {
      // Transition after a scrubber (outro) - position at the end of left scrubber
      left = leftScrubber.left + leftScrubber.width - width;
      top = leftScrubber.y * DEFAULT_TRACK_HEIGHT;
    } else if (rightScrubber) {
      // Transition before a scrubber (intro) - position at the start of right scrubber
      left = rightScrubber.left;
      top = rightScrubber.y * DEFAULT_TRACK_HEIGHT;
    }

    return {
      position: 'absolute' as const,
      left: `${left}px`,
      top: `${top + 10}px`, // Small offset from top
      width: `${width}px`,
      height: `${DEFAULT_TRACK_HEIGHT - 20}px`, // Smaller than track height
      zIndex: 50,
    };
  };

  const renderTransitionIcon = () => {
    const baseClasses = "absolute rounded-sm opacity-70";

    switch (transition.presentation) {
      case "fade":
        return (
          <div className="relative w-full h-full bg-gradient-to-r from-blue-500/50 to-blue-300/50 rounded-sm">
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
          </div>
        );
      case "slide":
        return (
          <div className="relative w-full h-full bg-gradient-to-r from-pink-500/50 to-pink-300/50 rounded-sm">
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent transform skew-x-12" />
          </div>
        );
      case "wipe":
        return (
          <div className="relative w-full h-full bg-gradient-to-r from-green-500/50 to-green-300/50 rounded-sm">
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
          </div>
        );
      case "flip":
        return (
          <div className="relative w-full h-full bg-gradient-to-r from-purple-500/50 to-purple-300/50 rounded-sm">
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent transform -skew-y-3" />
          </div>
        );
      case "clockWipe":
        return (
          <div className="relative w-full h-full bg-gradient-to-r from-orange-500/50 to-orange-300/50 rounded-sm">
            <div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
              style={{ clipPath: "polygon(50% 50%, 50% 0%, 100% 0%, 75% 100%)" }}
            />
          </div>
        );
      case "iris":
        return (
          <div className="relative w-full h-full bg-gradient-to-r from-teal-500/50 to-teal-300/50 rounded-sm">
            <div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
              style={{ clipPath: "circle(30% at 50% 50%)" }}
            />
          </div>
        );
      default:
        return (
          <div className="w-full h-full bg-gradient-to-r from-gray-500/50 to-gray-300/50 rounded-sm" />
        );
    }
  };

  return (
    <div
      style={getTransitionStyle()}
      className="border border-border/50 rounded-sm cursor-pointer transition-all hover:border-border hover:shadow-md"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Transition visual effect */}
      {renderTransitionIcon()}

      {/* Delete button - shown on hover */}
      {isHovered && (
        <Button
          variant="destructive"
          size="sm"
          className="absolute -top-2 -right-2 w-6 h-6 p-0 rounded-full shadow-md"
          onClick={(e) => {
            e.stopPropagation();
            onDelete(transition.id);
          }}
        >
          <X className="w-3 h-3" />
        </Button>
      )}

      {/* Transition label */}
      <div className="absolute bottom-0 left-0 right-0 px-1 py-0.5 bg-black/50 text-white text-xs rounded-b-sm truncate">
        {transition.presentation}
      </div>
    </div>
  );
}; 


================================================
FILE: app/components/timeline/types.ts
================================================
// base type for all scrubbers
export interface BaseScrubber {
  id: string;
  mediaType: "video" | "image" | "audio" | "text" | "groupped_scrubber";
  mediaUrlLocal: string | null; // null for text
  mediaUrlRemote: string | null;
  media_width: number; // width of the media in pixels
  media_height: number; // height of the media in pixels

  text: TextProperties | null;
  groupped_scrubbers: ScrubberState[] | null; // null for not grouped
  //  groupped_scrubber_transitions: Transition[] | null; // null for no transitions / not groupped scrubbers [this is written to help with deepcopy]

  // transitions are managed using the right transition id, as in what to add to the right. Convenient to think of. Left one is for the initial transition, first scrubber intro. we won't use it anywhere else.
  // for a middle transition, you will only see its information in the left scrubber.
  left_transition_id: string | null; // only use this for the first scrubber intro
  right_transition_id: string | null; // this is what you use everywhere
}

export interface Transition {
  id: string;
  presentation: "fade" | "wipe" | "clockWipe" | "slide" | "flip" | "iris";
  timing: "spring" | "linear";
  durationInFrames: number;
  leftScrubberId: string | null; // ID of the scrubber this transition starts from. null for the first scrubber in a track
  rightScrubberId: string | null; // ID of the scrubber this transition goes to. null for the last scrubber in a track
  // trackId: string;         // Track where this transition exists
}

export interface TextProperties {
  textContent: string; // Only present when mediaType is "text"
  fontSize: number;
  fontFamily: string;
  color: string;
  textAlign: "left" | "center" | "right";
  fontWeight: "normal" | "bold";
  template: "normal" | "glassy" | null;          // template uses tiktok style pages. null for normal text. templates might override the text properties.
}

// state of the scrubber in the media bin
export interface MediaBinItem extends BaseScrubber {
  name: string;
  durationInSeconds: number; // For media, to calculate initial width

  // Upload tracking properties
  uploadProgress: number | null; // 0-100, null when upload complete
  isUploading: boolean; // True while upload is in progress
}

// state of the scrubber in the timeline
export interface ScrubberState extends MediaBinItem {
  left: number; // in pixels (for the scrubber in the timeline)
  y: number; // track position (0-based index)
  width: number; // width is a css property for the scrubber width
  sourceMediaBinId: string; // ID of the media bin item this scrubber was created from

  // the following are the properties of the scrubber in <Player>
  left_player: number;
  top_player: number;
  width_player: number;
  height_player: number;
  is_dragging: boolean;

  // for video scrubbers (and audio in the future)
  trimBefore: number | null; // in frames
  trimAfter: number | null; // in frames
}

// state of the track in the timeline
export interface TrackState {
  id: string;
  scrubbers: ScrubberState[];
  transitions: Transition[]; // Transitions between scrubbers on this track
}

// state of the timeline
export interface TimelineState {
  tracks: TrackState[];
}

// the most important type. gets converted to json and gets rendered. Everything else is just a helper type. (formed using getTimelineData() in useTimeline.ts from timelinestate)
export interface TimelineDataItem {
  scrubbers: (BaseScrubber & {
    startTime: number;
    endTime: number;
    duration: number; // TODO: this should be calculated from the start and end time, for trimming, it should be done with the trimmer. This should be refactored later.
    trackIndex: number; // track index in the timeline

    // the following are the properties of the scrubber in <Player>
    left_player: number;
    top_player: number;
    width_player: number;
    height_player: number;

    // for video scrubbers (and audio in the future)
    trimBefore: number | null; // in frames
    trimAfter: number | null; // in frames
  })[];
  transitions: { [id: string]: Transition };
}

// Constants
export const PIXELS_PER_SECOND = 100;
export const DEFAULT_TRACK_HEIGHT = 52;
export const FPS = 30;
export const RULER_HEIGHT = 24;

// Zoom constants
export const MIN_ZOOM = 0.25;
export const MAX_ZOOM = 4;
export const DEFAULT_ZOOM = 1;



================================================
FILE: app/components/ui/alert-dialog.tsx
================================================
"use client"

import * as React from "react"
import * as AlertDialogPrimitive from "@radix-ui/react-alert-dialog"

import { cn } from "~/lib/utils"
import { buttonVariants } from "~/components/ui/button"

function AlertDialog({
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Root>) {
  return <AlertDialogPrimitive.Root data-slot="alert-dialog" {...props} />
}

function AlertDialogTrigger({
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Trigger>) {
  return (
    <AlertDialogPrimitive.Trigger data-slot="alert-dialog-trigger" {...props} />
  )
}

function AlertDialogPortal({
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Portal>) {
  return (
    <AlertDialogPrimitive.Portal data-slot="alert-dialog-portal" {...props} />
  )
}

function AlertDialogOverlay({
  className,
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Overlay>) {
  return (
    <AlertDialogPrimitive.Overlay
      data-slot="alert-dialog-overlay"
      className={cn(
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        className
      )}
      {...props}
    />
  )
}

function AlertDialogContent({
  className,
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Content>) {
  return (
    <AlertDialogPortal>
      <AlertDialogOverlay />
      <AlertDialogPrimitive.Content
        data-slot="alert-dialog-content"
        className={cn(
          "bg-background data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-lg",
          className
        )}
        {...props}
      />
    </AlertDialogPortal>
  )
}

function AlertDialogHeader({
  className,
  ...props
}: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="alert-dialog-header"
      className={cn("flex flex-col gap-2 text-center sm:text-left", className)}
      {...props}
    />
  )
}

function AlertDialogFooter({
  className,
  ...props
}: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="alert-dialog-footer"
      className={cn(
        "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end",
        className
      )}
      {...props}
    />
  )
}

function AlertDialogTitle({
  className,
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Title>) {
  return (
    <AlertDialogPrimitive.Title
      data-slot="alert-dialog-title"
      className={cn("text-lg font-semibold", className)}
      {...props}
    />
  )
}

function AlertDialogDescription({
  className,
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Description>) {
  return (
    <AlertDialogPrimitive.Description
      data-slot="alert-dialog-description"
      className={cn("text-muted-foreground text-sm", className)}
      {...props}
    />
  )
}

function AlertDialogAction({
  className,
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Action>) {
  return (
    <AlertDialogPrimitive.Action
      className={cn(buttonVariants(), className)}
      {...props}
    />
  )
}

function AlertDialogCancel({
  className,
  ...props
}: React.ComponentProps<typeof AlertDialogPrimitive.Cancel>) {
  return (
    <AlertDialogPrimitive.Cancel
      className={cn(buttonVariants({ variant: "outline" }), className)}
      {...props}
    />
  )
}

export {
  AlertDialog,
  AlertDialogPortal,
  AlertDialogOverlay,
  AlertDialogTrigger,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogFooter,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogAction,
  AlertDialogCancel,
}



================================================
FILE: app/components/ui/AuthOverlay.tsx
================================================
import { Loader2 } from "lucide-react";
import { FaGoogle } from "react-icons/fa";
import { Button } from "~/components/ui/button";

interface AuthOverlayProps {
  isLoading: boolean; // kept for compatibility
  isSigningIn?: boolean;
  onSignIn: () => void;
}

export function AuthOverlay({
  isLoading: _isLoading,
  isSigningIn,
  onSignIn,
}: AuthOverlayProps) {
  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-gradient-to-b from-background/10 via-background/70 to-background/95 backdrop-blur-sm" />
      <div className="relative z-10 w-full max-w-lg">
        <div className="text-center p-6 rounded-xl border border-border/30 bg-background/50">
          <div className="text-2xl font-semibold mb-2">Code with Kimu</div>
          <p className="text-sm text-muted-foreground mb-2">
            Please log in to use the alpha editor.
          </p>
          <p className="text-xs text-muted-foreground mb-6">
            Kimu is a minimal, AI‑assisted video editor focused on speed and
            clarity. We don’t post anything on your behalf. Signing in only
            creates a private account for saving your projects and enabling
            secure access.
          </p>
          <Button
            onClick={onSignIn}
            disabled={!!isSigningIn}
            className="inline-flex items-center gap-2"
          >
            {isSigningIn ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Signing in...
              </>
            ) : (
              <>
                <FaGoogle className="h-4 w-4" />
                Continue with Google
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  );
}



================================================
FILE: app/components/ui/badge.tsx
================================================
import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "~/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center justify-center rounded-md border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden",
  {
    variants: {
      variant: {
        default:
          "border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
        secondary:
          "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
        destructive:
          "border-transparent bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
        outline:
          "text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
);

function Badge({
  className,
  variant,
  asChild = false,
  ...props
}: React.ComponentProps<"span"> &
  VariantProps<typeof badgeVariants> & { asChild?: boolean }) {
  const Comp = asChild ? Slot : "span";

  return (
    <Comp
      data-slot="badge"
      className={cn(badgeVariants({ variant }), className)}
      {...props}
    />
  );
}

export { Badge, badgeVariants };



================================================
FILE: app/components/ui/button.tsx
================================================
import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "~/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
        destructive:
          "bg-destructive text-white shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
        outline:
          "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50",
        secondary:
          "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
        ghost:
          "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-4 py-2 has-[>svg]:px-3",
        sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
        lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
        icon: "size-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

function Button({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean;
  }) {
  const Comp = asChild ? Slot : "button";

  return (
    <Comp
      data-slot="button"
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}

export { Button, buttonVariants };



================================================
FILE: app/components/ui/card-hover-effect.tsx
================================================
import { cn } from "~/lib/utils";
import { AnimatePresence, motion } from "motion/react";
import { useState } from "react";

export const HoverEffect = ({
  items,
  className,
}: {
  items: {
    title: string;
    description: string;
    link: string;
  }[];
  className?: string;
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <div className={cn("grid grid-cols-1 md:grid-cols-2  lg:grid-cols-3  p-10", className)}>
      {items.map((item, idx) => (
        <a
          href={item?.link}
          key={item?.link}
          className="relative group  block p-2 h-full w-full"
          onMouseEnter={() => setHoveredIndex(idx)}
          onMouseLeave={() => setHoveredIndex(null)}>
          <AnimatePresence>
            {hoveredIndex === idx && (
              <motion.span
                className="absolute inset-1 h-[calc(100%-8px)] w-[calc(100%-8px)] bg-neutral-200/50 dark:bg-neutral-800/70 rounded-2xl border border-neutral-700/60"
                layoutId="hoverBackground"
                initial={{ opacity: 0 }}
                animate={{
                  opacity: 1,
                  transition: { duration: 0.15 },
                }}
                exit={{
                  opacity: 0,
                  transition: { duration: 0.15, delay: 0.2 },
                }}
              />
            )}
          </AnimatePresence>
          <Card>
            <CardTitle>{item.title}</CardTitle>
            <CardDescription>{item.description}</CardDescription>
          </Card>
        </a>
      ))}
    </div>
  );
};

export const Card = ({ className, children }: { className?: string; children: React.ReactNode }) => {
  return (
    <div
      className={cn(
        "rounded-2xl h-full w-full p-4 overflow-hidden bg-black border border-transparent dark:border-white/[0.2] group-hover:border-slate-700 relative z-20",
        className,
      )}>
      <div className="relative z-50">
        <div className="p-4">{children}</div>
      </div>
    </div>
  );
};

export const CardTitle = ({ className, children }: { className?: string; children: React.ReactNode }) => {
  return <h4 className={cn("text-zinc-100 font-bold tracking-wide mt-4", className)}>{children}</h4>;
};

export const CardDescription = ({ className, children }: { className?: string; children: React.ReactNode }) => {
  return <p className={cn("mt-8 text-zinc-400 tracking-wide leading-relaxed text-sm", className)}>{children}</p>;
};



================================================
FILE: app/components/ui/card.tsx
================================================
import * as React from "react";

import { cn } from "~/lib/utils";

function Card({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="card"
      className={cn("bg-card text-card-foreground flex flex-col gap-6 rounded-xl border shadow-sm", className)}
      {...props}
    />
  );
}

function CardHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="card-header"
      className={cn(
        "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-1.5 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6",
        className,
      )}
      {...props}
    />
  );
}

function CardTitle({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="card-title" className={cn("leading-none font-semibold", className)} {...props} />;
}

function CardDescription({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="card-description" className={cn("text-muted-foreground text-sm", className)} {...props} />;
}

function CardAction({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="card-action"
      className={cn("col-start-2 row-span-2 row-start-1 self-start justify-self-end", className)}
      {...props}
    />
  );
}

function CardContent({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="card-content" className={cn("px-6", className)} {...props} />;
}

function CardFooter({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div data-slot="card-footer" className={cn("flex items-center px-6 [.border-t]:pt-6", className)} {...props} />
  );
}

export { Card, CardHeader, CardFooter, CardTitle, CardAction, CardDescription, CardContent };



================================================
FILE: app/components/ui/drawer.tsx
================================================
import * as React from "react";
import { Drawer as DrawerPrimitive } from "vaul";

import { cn } from "~/lib/utils";

function Drawer({ ...props }: React.ComponentProps<typeof DrawerPrimitive.Root>) {
  return <DrawerPrimitive.Root data-slot="drawer" {...props} />;
}

function DrawerTrigger({ ...props }: React.ComponentProps<typeof DrawerPrimitive.Trigger>) {
  return <DrawerPrimitive.Trigger data-slot="drawer-trigger" {...props} />;
}

function DrawerPortal({ ...props }: React.ComponentProps<typeof DrawerPrimitive.Portal>) {
  return <DrawerPrimitive.Portal data-slot="drawer-portal" {...props} />;
}

function DrawerClose({ ...props }: React.ComponentProps<typeof DrawerPrimitive.Close>) {
  return <DrawerPrimitive.Close data-slot="drawer-close" {...props} />;
}

function DrawerOverlay({ className, ...props }: React.ComponentProps<typeof DrawerPrimitive.Overlay>) {
  return (
    <DrawerPrimitive.Overlay
      data-slot="drawer-overlay"
      className={cn(
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        className,
      )}
      {...props}
    />
  );
}

function DrawerContent({ className, children, ...props }: React.ComponentProps<typeof DrawerPrimitive.Content>) {
  return (
    <DrawerPortal data-slot="drawer-portal">
      <DrawerOverlay />
      <DrawerPrimitive.Content
        data-slot="drawer-content"
        className={cn(
          "group/drawer-content bg-background fixed z-50 flex h-auto flex-col",
          "data-[vaul-drawer-direction=top]:inset-x-0 data-[vaul-drawer-direction=top]:top-0 data-[vaul-drawer-direction=top]:mb-24 data-[vaul-drawer-direction=top]:max-h-[80vh] data-[vaul-drawer-direction=top]:rounded-b-lg data-[vaul-drawer-direction=top]:border-b",
          "data-[vaul-drawer-direction=bottom]:inset-x-0 data-[vaul-drawer-direction=bottom]:bottom-0 data-[vaul-drawer-direction=bottom]:mt-24 data-[vaul-drawer-direction=bottom]:max-h-[80vh] data-[vaul-drawer-direction=bottom]:rounded-t-lg data-[vaul-drawer-direction=bottom]:border-t",
          "data-[vaul-drawer-direction=right]:inset-y-0 data-[vaul-drawer-direction=right]:right-0 data-[vaul-drawer-direction=right]:w-full data-[vaul-drawer-direction=right]:max-w-[520px] data-[vaul-drawer-direction=right]:sm:max-w-[560px] data-[vaul-drawer-direction=right]:border-l",
          "data-[vaul-drawer-direction=left]:inset-y-0 data-[vaul-drawer-direction=left]:left-0 data-[vaul-drawer-direction=left]:w-3/4 data-[vaul-drawer-direction=left]:border-r data-[vaul-drawer-direction=left]:sm:max-w-sm",
          className,
        )}
        {...props}>
        <div className="bg-muted mx-auto mt-4 hidden h-2 w-[100px] shrink-0 rounded-full group-data-[vaul-drawer-direction=bottom]/drawer-content:block" />
        {children}
      </DrawerPrimitive.Content>
    </DrawerPortal>
  );
}

function DrawerHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="drawer-header"
      className={cn(
        "flex flex-col gap-0.5 p-4 group-data-[vaul-drawer-direction=bottom]/drawer-content:text-center group-data-[vaul-drawer-direction=top]/drawer-content:text-center md:gap-1.5 md:text-left",
        className,
      )}
      {...props}
    />
  );
}

function DrawerFooter({ className, ...props }: React.ComponentProps<"div">) {
  return <div data-slot="drawer-footer" className={cn("mt-auto flex flex-col gap-2 p-4", className)} {...props} />;
}

function DrawerTitle({ className, ...props }: React.ComponentProps<typeof DrawerPrimitive.Title>) {
  return (
    <DrawerPrimitive.Title
      data-slot="drawer-title"
      className={cn("text-foreground font-semibold", className)}
      {...props}
    />
  );
}

function DrawerDescription({ className, ...props }: React.ComponentProps<typeof DrawerPrimitive.Description>) {
  return (
    <DrawerPrimitive.Description
      data-slot="drawer-description"
      className={cn("text-muted-foreground text-sm", className)}
      {...props}
    />
  );
}

export {
  Drawer,
  DrawerPortal,
  DrawerOverlay,
  DrawerTrigger,
  DrawerClose,
  DrawerContent,
  DrawerHeader,
  DrawerFooter,
  DrawerTitle,
  DrawerDescription,
};



================================================
FILE: app/components/ui/dropdown-menu.tsx
================================================
"use client"

import * as React from "react"
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu"
import { CheckIcon, ChevronRightIcon, CircleIcon } from "lucide-react"

import { cn } from "~/lib/utils"

function DropdownMenu({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Root>) {
  return <DropdownMenuPrimitive.Root data-slot="dropdown-menu" {...props} />
}

function DropdownMenuPortal({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Portal>) {
  return (
    <DropdownMenuPrimitive.Portal data-slot="dropdown-menu-portal" {...props} />
  )
}

function DropdownMenuTrigger({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Trigger>) {
  return (
    <DropdownMenuPrimitive.Trigger
      data-slot="dropdown-menu-trigger"
      {...props}
    />
  )
}

function DropdownMenuContent({
  className,
  sideOffset = 4,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Content>) {
  return (
    <DropdownMenuPrimitive.Portal>
      <DropdownMenuPrimitive.Content
        data-slot="dropdown-menu-content"
        sideOffset={sideOffset}
        className={cn(
          "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 max-h-(--radix-dropdown-menu-content-available-height) min-w-[8rem] origin-(--radix-dropdown-menu-content-transform-origin) overflow-x-hidden overflow-y-auto rounded-md border p-1 shadow-md",
          className
        )}
        {...props}
      />
    </DropdownMenuPrimitive.Portal>
  )
}

function DropdownMenuGroup({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Group>) {
  return (
    <DropdownMenuPrimitive.Group data-slot="dropdown-menu-group" {...props} />
  )
}

function DropdownMenuItem({
  className,
  inset,
  variant = "default",
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Item> & {
  inset?: boolean
  variant?: "default" | "destructive"
}) {
  return (
    <DropdownMenuPrimitive.Item
      data-slot="dropdown-menu-item"
      data-inset={inset}
      data-variant={variant}
      className={cn(
        "focus:bg-accent focus:text-accent-foreground data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:!text-destructive [&_svg:not([class*='text-'])]:text-muted-foreground relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 data-[inset]:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      {...props}
    />
  )
}

function DropdownMenuCheckboxItem({
  className,
  children,
  checked,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.CheckboxItem>) {
  return (
    <DropdownMenuPrimitive.CheckboxItem
      data-slot="dropdown-menu-checkbox-item"
      className={cn(
        "focus:bg-accent focus:text-accent-foreground relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      checked={checked}
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <DropdownMenuPrimitive.ItemIndicator>
          <CheckIcon className="size-4" />
        </DropdownMenuPrimitive.ItemIndicator>
      </span>
      {children}
    </DropdownMenuPrimitive.CheckboxItem>
  )
}

function DropdownMenuRadioGroup({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.RadioGroup>) {
  return (
    <DropdownMenuPrimitive.RadioGroup
      data-slot="dropdown-menu-radio-group"
      {...props}
    />
  )
}

function DropdownMenuRadioItem({
  className,
  children,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.RadioItem>) {
  return (
    <DropdownMenuPrimitive.RadioItem
      data-slot="dropdown-menu-radio-item"
      className={cn(
        "focus:bg-accent focus:text-accent-foreground relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <DropdownMenuPrimitive.ItemIndicator>
          <CircleIcon className="size-2 fill-current" />
        </DropdownMenuPrimitive.ItemIndicator>
      </span>
      {children}
    </DropdownMenuPrimitive.RadioItem>
  )
}

function DropdownMenuLabel({
  className,
  inset,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Label> & {
  inset?: boolean
}) {
  return (
    <DropdownMenuPrimitive.Label
      data-slot="dropdown-menu-label"
      data-inset={inset}
      className={cn(
        "px-2 py-1.5 text-sm font-medium data-[inset]:pl-8",
        className
      )}
      {...props}
    />
  )
}

function DropdownMenuSeparator({
  className,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Separator>) {
  return (
    <DropdownMenuPrimitive.Separator
      data-slot="dropdown-menu-separator"
      className={cn("bg-border -mx-1 my-1 h-px", className)}
      {...props}
    />
  )
}

function DropdownMenuShortcut({
  className,
  ...props
}: React.ComponentProps<"span">) {
  return (
    <span
      data-slot="dropdown-menu-shortcut"
      className={cn(
        "text-muted-foreground ml-auto text-xs tracking-widest",
        className
      )}
      {...props}
    />
  )
}

function DropdownMenuSub({
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.Sub>) {
  return <DropdownMenuPrimitive.Sub data-slot="dropdown-menu-sub" {...props} />
}

function DropdownMenuSubTrigger({
  className,
  inset,
  children,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.SubTrigger> & {
  inset?: boolean
}) {
  return (
    <DropdownMenuPrimitive.SubTrigger
      data-slot="dropdown-menu-sub-trigger"
      data-inset={inset}
      className={cn(
        "focus:bg-accent focus:text-accent-foreground data-[state=open]:bg-accent data-[state=open]:text-accent-foreground flex cursor-default items-center rounded-sm px-2 py-1.5 text-sm outline-hidden select-none data-[inset]:pl-8",
        className
      )}
      {...props}
    >
      {children}
      <ChevronRightIcon className="ml-auto size-4" />
    </DropdownMenuPrimitive.SubTrigger>
  )
}

function DropdownMenuSubContent({
  className,
  ...props
}: React.ComponentProps<typeof DropdownMenuPrimitive.SubContent>) {
  return (
    <DropdownMenuPrimitive.SubContent
      data-slot="dropdown-menu-sub-content"
      className={cn(
        "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 min-w-[8rem] origin-(--radix-dropdown-menu-content-transform-origin) overflow-hidden rounded-md border p-1 shadow-lg",
        className
      )}
      {...props}
    />
  )
}

export {
  DropdownMenu,
  DropdownMenuPortal,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuLabel,
  DropdownMenuItem,
  DropdownMenuCheckboxItem,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuSub,
  DropdownMenuSubTrigger,
  DropdownMenuSubContent,
}



================================================
FILE: app/components/ui/following-pointer.tsx
================================================
import React, { useEffect, useState } from "react";

import { motion, AnimatePresence, useMotionValue, MotionValue } from "framer-motion";
import { cn } from "~/lib/utils";

export const FollowerPointerCard = ({
  children,
  className,
  title,
}: {
  children: React.ReactNode;
  className?: string;
  title?: string | React.ReactNode;
}) => {
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const ref = React.useRef<HTMLDivElement>(null);
  const [rect, setRect] = useState<DOMRect | null>(null);
  const [isInside, setIsInside] = useState<boolean>(false);

  useEffect(() => {
    if (ref.current) {
      setRect(ref.current.getBoundingClientRect());
    }
  }, []);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (rect) {
      const scrollX = window.scrollX;
      const scrollY = window.scrollY;
      x.set(e.clientX - rect.left + scrollX);
      y.set(e.clientY - rect.top + scrollY);
    }
  };
  const handleMouseLeave = () => {
    setIsInside(false);
  };

  const handleMouseEnter = () => {
    setIsInside(true);
  };
  return (
    <div
      onMouseLeave={handleMouseLeave}
      onMouseEnter={handleMouseEnter}
      onMouseMove={handleMouseMove}
      style={{ cursor: "none" }}
      ref={ref}
      className={cn("relative", className)}
    >
      <AnimatePresence>
        {isInside && <FollowPointer x={x} y={y} title={title} />}
      </AnimatePresence>
      {children}
    </div>
  );
};

export const FollowPointer = ({
  x,
  y,
  title,
}: {
  x: MotionValue<number>;
  y: MotionValue<number>;
  title?: string | React.ReactNode;
}) => {
  const pillColor = "#fb7185"; // rose-400 (lighter)
  return (
    <motion.div
      className="absolute z-50 h-4 w-4 rounded-full"
      style={{ top: y, left: x, pointerEvents: "none" }}
      initial={{ scale: 1, opacity: 1 }}
      animate={{ scale: 1, opacity: 1 }}
      exit={{ scale: 0, opacity: 0 }}
    >
      <svg
        stroke="currentColor"
        fill="currentColor"
        strokeWidth="1"
        viewBox="0 0 16 16"
        className="h-6 w-6 -translate-x-[12px] -translate-y-[10px] -rotate-[70deg] transform stroke-rose-400 text-rose-300"
        height="1em"
        width="1em"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M14.082 2.182a.5.5 0 0 1 .103.557L8.528 15.467a.5.5 0 0 1-.917-.007L5.57 10.694.803 8.652a.5.5 0 0 1-.006-.916l12.728-5.657a.5.5 0 0 1 .556.103z" />
      </svg>
      <motion.div
        style={{ backgroundColor: pillColor, position: "absolute", left: 10, top: -8 }}
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="min-w-max rounded-full ml-2 mt-2 px-2 py-0.5 text-[10px] font-medium whitespace-nowrap text-white shadow"
      >
        {title || `you`}
      </motion.div>
    </motion.div>
  );
};





================================================
FILE: app/components/ui/Footer.tsx
================================================
import { KimuLogo } from "~/components/ui/KimuLogo";

export function Footer() {
  return (
    <footer className="w-full border-t border-border/30 bg-background/70 backdrop-blur supports-[backdrop-filter]:bg-background/50">
      <div className="max-w-7xl mx-auto px-6 py-4 flex flex-col md:flex-row items-center justify-between gap-3 text-xs text-muted-foreground">
        <div className="inline-flex items-center gap-2">
          <KimuLogo className="w-4 h-4" />
          <span>© {new Date().getFullYear()} Kimu Studio</span>
        </div>
        <nav className="flex flex-wrap items-center gap-4">
          <a href="http://deepwiki.com/trykimu/videoeditor/" target="_blank" rel="noreferrer" className="hover:text-foreground">Docs</a>
          <a href="/privacy" className="hover:text-foreground">Privacy</a>
          <a href="/terms" className="hover:text-foreground">Terms</a>
          <a href="/marketplace" className="hover:text-foreground">Marketplace</a>
          <a href="/roadmap" className="hover:text-foreground">Roadmap</a>
          <a href="https://github.com/trykimu/videoeditor" target="_blank" rel="noreferrer" className="hover:text-foreground">GitHub</a>
          <a href="https://discord.gg/24Mt5DGcbx" target="_blank" rel="noreferrer" className="hover:text-foreground">Discord</a>
          <a href="https://twitter.com/trykimu" target="_blank" rel="noreferrer" className="hover:text-foreground">Twitter</a>
        </nav>
      </div>
    </footer>
  );
}









================================================
FILE: app/components/ui/glowing-effect.tsx
================================================
"use client";

import { memo, useCallback, useEffect, useRef } from "react";
import { cn } from "~/lib/utils";
import { animate } from "motion/react";

interface GlowingEffectProps {
  blur?: number;
  inactiveZone?: number;
  proximity?: number;
  spread?: number;
  variant?: "default" | "white";
  glow?: boolean;
  className?: string;
  disabled?: boolean;
  movementDuration?: number;
  borderWidth?: number;
  hoverBorderWidth?: number;
}
const GlowingEffect = memo(
  ({
    blur = 0,
    inactiveZone = 0.7,
    proximity = 0,
    spread = 20,
    variant = "default",
    glow = false,
    className,
    movementDuration = 2,
    borderWidth = 1,
    hoverBorderWidth,
    disabled = true,
  }: GlowingEffectProps) => {
    const containerRef = useRef<HTMLDivElement>(null);
    const lastPosition = useRef({ x: 0, y: 0 });
    const animationFrameRef = useRef<number>(0);

    const handleMove = useCallback(
      (e?: MouseEvent | { x: number; y: number }) => {
        if (!containerRef.current) return;

        if (animationFrameRef.current) {
          cancelAnimationFrame(animationFrameRef.current);
        }

        animationFrameRef.current = requestAnimationFrame(() => {
          const element = containerRef.current;
          if (!element) return;

          const { left, top, width, height } = element.getBoundingClientRect();
          const mouseX = e?.x ?? lastPosition.current.x;
          const mouseY = e?.y ?? lastPosition.current.y;

          if (e) {
            lastPosition.current = { x: mouseX, y: mouseY };
          }

          const center = [left + width * 0.5, top + height * 0.5];
          const distanceFromCenter = Math.hypot(
            mouseX - center[0],
            mouseY - center[1]
          );
          const inactiveRadius = 0.5 * Math.min(width, height) * inactiveZone;

          if (distanceFromCenter < inactiveRadius) {
            element.style.setProperty("--active", "0");
            return;
          }

          const isActive =
            mouseX > left - proximity &&
            mouseX < left + width + proximity &&
            mouseY > top - proximity &&
            mouseY < top + height + proximity;

          element.style.setProperty("--active", isActive ? "1" : "0");

          if (!isActive) return;

          const currentAngle =
            parseFloat(element.style.getPropertyValue("--start")) || 0;
          const targetAngle =
            (180 * Math.atan2(mouseY - center[1], mouseX - center[0])) /
              Math.PI +
            90;

          const angleDiff = ((targetAngle - currentAngle + 180) % 360) - 180;
          const newAngle = currentAngle + angleDiff;

          animate(currentAngle, newAngle, {
            duration: movementDuration,
            ease: [0.16, 1, 0.3, 1],
            onUpdate: (value) => {
              element.style.setProperty("--start", String(value));
            },
          });
        });
      },
      [inactiveZone, proximity, movementDuration]
    );

    useEffect(() => {
      if (disabled) return;

      const handleScroll = () => handleMove();
      const handlePointerMove = (e: PointerEvent) => handleMove(e);

      window.addEventListener("scroll", handleScroll, { passive: true });
      document.body.addEventListener("pointermove", handlePointerMove, {
        passive: true,
      });

      return () => {
        if (animationFrameRef.current) {
          cancelAnimationFrame(animationFrameRef.current);
        }
        window.removeEventListener("scroll", handleScroll);
        document.body.removeEventListener("pointermove", handlePointerMove);
      };
    }, [handleMove, disabled]);

    // Increase outline thickness on hover of the parent container
    useEffect(() => {
      const container = containerRef.current;
      if (!container) return;
      const parent = container.parentElement;
      if (!parent) return;

      const enter = () =>
        container.style.setProperty(
          "--glowingeffect-border-width",
          `${hoverBorderWidth ?? Math.max(borderWidth * 2, borderWidth + 1)}px`
        );
      const leave = () =>
        container.style.setProperty(
          "--glowingeffect-border-width",
          `${borderWidth}px`
        );

      parent.addEventListener("mouseenter", enter);
      parent.addEventListener("mouseleave", leave);
      return () => {
        parent.removeEventListener("mouseenter", enter);
        parent.removeEventListener("mouseleave", leave);
      };
    }, [borderWidth, hoverBorderWidth]);

    return (
      <>
        <div
          className={cn(
            "pointer-events-none absolute -inset-px hidden rounded-[inherit] border opacity-0 transition-opacity",
            glow && "opacity-100",
            variant === "white" && "border-white",
            disabled && "!block"
          )}
        />
        <div
          ref={containerRef}
          style={
            {
              "--blur": `${blur}px`,
              "--spread": spread,
              "--start": "0",
              "--active": "0",
              "--glowingeffect-border-width": `${borderWidth}px`,
              "--repeating-conic-gradient-times": "5",
              "--gradient":
                variant === "white"
                  ? `repeating-conic-gradient(
                  from 236.84deg at 50% 50%,
                  var(--black),
                  var(--black) calc(25% / var(--repeating-conic-gradient-times))
                )`
                  : `radial-gradient(circle, #dd7bbb 10%, #dd7bbb00 20%),
                radial-gradient(circle at 40% 40%, #d79f1e 5%, #d79f1e00 15%),
                radial-gradient(circle at 60% 60%, #5a922c 10%, #5a922c00 20%), 
                radial-gradient(circle at 40% 60%, #4c7894 10%, #4c789400 20%),
                repeating-conic-gradient(
                  from 236.84deg at 50% 50%,
                  #dd7bbb 0%,
                  #d79f1e calc(25% / var(--repeating-conic-gradient-times)),
                  #5a922c calc(50% / var(--repeating-conic-gradient-times)), 
                  #4c7894 calc(75% / var(--repeating-conic-gradient-times)),
                  #dd7bbb calc(100% / var(--repeating-conic-gradient-times))
                )`,
            } as React.CSSProperties
          }
          className={cn(
            "pointer-events-none absolute inset-0 rounded-[inherit] opacity-100 transition-opacity",
            glow && "opacity-100",
            blur > 0 && "blur-[var(--blur)] ",
            className,
            disabled && "!hidden"
          )}
        >
          <div
            className={cn(
              "glow",
              "rounded-[inherit]",
              'after:content-[""] after:rounded-[inherit] after:absolute after:inset-[calc(-1*var(--glowingeffect-border-width))]',
              "after:[border:var(--glowingeffect-border-width)_solid_transparent]",
              "after:[background:var(--gradient)] after:[background-attachment:fixed]",
              "after:opacity-[var(--active)] after:transition-opacity after:duration-300",
              "after:[mask-clip:padding-box,border-box]",
              "after:[mask-composite:intersect]",
              "after:[mask-image:linear-gradient(#0000,#0000),conic-gradient(from_calc((var(--start)-var(--spread))*1deg),#00000000_0deg,#fff,#00000000_calc(var(--spread)*2deg))]"
            )}
          />
        </div>
      </>
    );
  }
);

GlowingEffect.displayName = "GlowingEffect";

export { GlowingEffect };



================================================
FILE: app/components/ui/input.tsx
================================================
import * as React from "react"

import { cn } from "~/lib/utils"

function Input({ className, type, ...props }: React.ComponentProps<"input">) {
  return (
    <input
      type={type}
      data-slot="input"
      className={cn(
        "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input flex h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        className
      )}
      {...props}
    />
  )
}

export { Input }



================================================
FILE: app/components/ui/KimuLogo.tsx
================================================
import * as React from "react";

interface KimuLogoProps extends React.SVGProps<SVGSVGElement> {
  color?: string; // CSS color or tailwind class
  opacity?: number;
  animated?: boolean;
}

export const KimuLogo: React.FC<KimuLogoProps> = ({
  color = "currentColor",
  opacity = 1,
  className = "",
  animated = false,
  style,
  ...rest
}) => {
  return (
    <svg
      width="80"
      height="80"
      viewBox="0 0 630 625"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={
        className +
        (animated
          ? " animate-float-icon transition-all duration-700"
          : "")
      }
      style={{ color, opacity, ...(style as React.CSSProperties) }}
      {...rest}
      aria-label="Kimu Logo"
    >
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M279.396 5.1936C214.433 22.5977 158.93 78.5278 150.548 135.039L147.934 152.663L131.558 154.415C55.5273 162.562 0.269333 223.182 0.00250518 298.735C-0.0889079 324.563 2.30266 338.559 10.2605 358.759C16.0912 373.558 32.6123 397.596 45.3237 409.772C53.3384 417.45 53.7337 418.572 51.8486 428.311C48.5108 445.554 49.3681 462.828 54.5687 483.171C61.1134 508.776 69.2368 525.985 84.4929 546.578C130.493 608.656 203.918 635.742 255.925 609.815C261.36 607.106 277.496 593.397 291.783 579.352L317.759 553.816L324.919 567.497C334.965 586.691 349.579 600.743 370.275 611.103C394.42 623.187 410.791 626.198 443.692 624.609C514.443 621.188 577.486 578.346 601.029 517.692C605.533 506.087 606.736 498.207 606.672 480.699C606.595 460.002 605.866 456.816 596.172 434.965C590.442 422.047 585.753 410.539 585.753 409.392C585.753 408.242 590.237 402.206 595.72 395.975C607.949 382.075 621.404 355.088 626.805 333.625C632.465 311.137 630.397 274 622.244 251.758C600.715 193.018 548.489 152.823 488.168 148.569L465.928 147.002L458.466 132.171C454.363 124.014 443.317 100.856 433.918 80.7079C410.183 29.8204 396.706 15.8224 360.617 4.58553C340.247 -1.75718 304.334 -1.48775 279.396 5.1936ZM434.373 245.952C450.667 252.762 460.001 261.922 467.934 278.882C486.424 318.414 471.072 371.461 433.901 396.469C420.928 405.197 417.588 406.277 400.557 407.263C378.917 408.519 368.066 404.49 354.258 390.077C314.236 348.296 338.75 261.747 395.5 244.476C406.035 241.27 424.888 241.987 434.373 245.952ZM280.631 252.992C324.299 276.442 317.784 362.852 270.067 393.129C253.35 403.736 241.313 406.47 226.425 403.044C209.274 399.096 198.614 390.03 190.199 372.235C175.516 341.184 182.639 298.594 207.031 271.58C219.216 258.086 228.898 251.598 242.186 248.018C255.747 244.365 267.366 245.868 280.631 252.992Z"
        fill="currentColor"
      />
    </svg>
  );
};

export default KimuLogo; 


================================================
FILE: app/components/ui/label.tsx
================================================
import * as React from "react"
import * as LabelPrimitive from "@radix-ui/react-label"

import { cn } from "~/lib/utils"

function Label({
  className,
  ...props
}: React.ComponentProps<typeof LabelPrimitive.Root>) {
  return (
    <LabelPrimitive.Root
      data-slot="label"
      className={cn(
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        className
      )}
      {...props}
    />
  )
}

export { Label }



================================================
FILE: app/components/ui/MarketingFooter.tsx
================================================
import * as React from "react";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { ArrowRight } from "lucide-react";
import { toast } from "sonner";

export function MarketingFooter() {
  const [email, setEmail] = React.useState("");
  const [submitting, setSubmitting] = React.useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!email) return;
    setSubmitting(true);
    try {
      // Placeholder – integrate with your waitlist backend later
      await new Promise((r) => setTimeout(r, 600));
      toast.success("Thanks! We'll keep you posted.");
      setEmail("");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen w-full bg-background text-foreground flex flex-col justify-end">
      <div className="relative bg-white text-black overflow-hidden">
        {/* Black cap with rounded bottom corners */}
        <div className="absolute top-0 left-0 right-0 h-8 sm:h-10 bg-background rounded-b-[3rem] pointer-events-none" />
        {/* Subtle background texture */}
        <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_20%_0%,rgba(0,0,0,0.06),transparent_40%),radial-gradient(circle_at_80%_20%,rgba(0,0,0,0.05),transparent_45%)]" />

        {/* Footer Links Section */}
        <footer className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 pt-20 sm:pt-24 pb-[40vw] sm:pb-[32vw] md:pb-[22vw] grid grid-cols-1 md:grid-cols-12 gap-y-10 md:gap-y-12 gap-x-12 md:gap-x-16 font-mono">
          {/* Left column + Waitlist & Newsletter */}
          <div className="flex flex-col space-y-6 md:col-span-5 font-sans min-w-0">
            <KimuLogo className="w-10 h-10 text-black" />
            <div className="mt-10 max-w-md">
              <form onSubmit={handleSubmit} className="w-full">
                <div className="text-[11px] uppercase tracking-[0.15em] text-black/60 mb-4">
                  Waitlist & Newsletter
                </div>
                <div className="relative flex items-center">
                  <div className="flex-1 border-b border-black/50">
                    <input
                      type="email"
                      placeholder="your@email.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      className="w-full bg-transparent outline-none border-0 text-3xl leading-none placeholder:text-black/30 text-black"
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={submitting || !email}
                    className="ml-3 h-8 w-8 rounded-full bg-black text-white grid place-items-center disabled:opacity-50 shrink-0"
                    aria-label="Subscribe"
                  >
                    <ArrowRight className="w-5 h-5" />
                  </button>
                </div>
              </form>
            </div>
          </div>

          {/* The Good */}
          <div className="md:col-start-7 md:col-span-2">
            <h3 className="font-semibold mb-3 uppercase">The Good</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="/" className="hover:underline">Home</a></li>
              <li><a href="http://deepwiki.com/trykimu/videoeditor/" target="_blank" rel="noreferrer" className="hover:underline">Docs</a></li>
              <li>
                <div className="inline-flex items-center gap-2">
                  <span>Plugins</span>
                  <span className="text-[10px] px-2 py-0.5 rounded-full border border-black/40 text-black/70">Coming soon</span>
                </div>
              </li>
            </ul>
          </div>

          {/* The Boring */}
          <div className="md:col-start-9 md:col-span-2">
            <h3 className="font-semibold mb-3 uppercase">The Boring</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="/terms" className="hover:underline">Terms of Use</a></li>
              <li><a href="/privacy" className="hover:underline">Play by the Rules</a></li>
            </ul>
          </div>

          {/* The Cool */}
          <div className="md:col-start-11 md:col-span-2">
            <h3 className="font-semibold mb-3 uppercase">The Cool</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="https://twitter.com/trykimu" target="_blank" rel="noreferrer" className="hover:underline">X</a></li>
              <li><a href="https://github.com/trykimu/videoeditor" target="_blank" rel="noreferrer" className="hover:underline">GitHub</a></li>
              <li><a href="https://discord.gg/24Mt5DGcbx" target="_blank" rel="noreferrer" className="hover:underline">Discord</a></li>
            </ul>
          </div>
        </footer>

        {/* Big KIMU wordmark pinned to the very bottom */}
        <div className="absolute bottom-0 left-0 right-0 flex justify-center pointer-events-none z-0">
          <h1 className="text-[16vw] md:text-[18vw] font-extrabold leading-none text-black/10 select-none tracking-tight">TRYKIMU</h1>
        </div>
      </div>
    </div>
  );
}





================================================
FILE: app/components/ui/menubar.tsx
================================================
import * as React from "react"
import * as MenubarPrimitive from "@radix-ui/react-menubar"
import { CheckIcon, ChevronRightIcon, CircleIcon } from "lucide-react"

import { cn } from "~/lib/utils"

function Menubar({
  className,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Root>) {
  return (
    <MenubarPrimitive.Root
      data-slot="menubar"
      className={cn(
        "bg-background flex h-9 items-center gap-1 rounded-md border p-1 shadow-xs",
        className
      )}
      {...props}
    />
  )
}

function MenubarMenu({
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Menu>) {
  return <MenubarPrimitive.Menu data-slot="menubar-menu" {...props} />
}

function MenubarGroup({
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Group>) {
  return <MenubarPrimitive.Group data-slot="menubar-group" {...props} />
}

function MenubarPortal({
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Portal>) {
  return <MenubarPrimitive.Portal data-slot="menubar-portal" {...props} />
}

function MenubarRadioGroup({
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.RadioGroup>) {
  return (
    <MenubarPrimitive.RadioGroup data-slot="menubar-radio-group" {...props} />
  )
}

function MenubarTrigger({
  className,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Trigger>) {
  return (
    <MenubarPrimitive.Trigger
      data-slot="menubar-trigger"
      className={cn(
        "focus:bg-accent focus:text-accent-foreground data-[state=open]:bg-accent data-[state=open]:text-accent-foreground flex items-center rounded-sm px-2 py-1 text-sm font-medium outline-hidden select-none",
        className
      )}
      {...props}
    />
  )
}

function MenubarContent({
  className,
  align = "start",
  alignOffset = -4,
  sideOffset = 8,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Content>) {
  return (
    <MenubarPortal>
      <MenubarPrimitive.Content
        data-slot="menubar-content"
        align={align}
        alignOffset={alignOffset}
        sideOffset={sideOffset}
        className={cn(
          "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 min-w-[12rem] origin-(--radix-menubar-content-transform-origin) overflow-hidden rounded-md border p-1 shadow-md",
          className
        )}
        {...props}
      />
    </MenubarPortal>
  )
}

function MenubarItem({
  className,
  inset,
  variant = "default",
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Item> & {
  inset?: boolean
  variant?: "default" | "destructive"
}) {
  return (
    <MenubarPrimitive.Item
      data-slot="menubar-item"
      data-inset={inset}
      data-variant={variant}
      className={cn(
        "focus:bg-accent focus:text-accent-foreground data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:!text-destructive [&_svg:not([class*='text-'])]:text-muted-foreground relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 data-[inset]:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      {...props}
    />
  )
}

function MenubarCheckboxItem({
  className,
  children,
  checked,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.CheckboxItem>) {
  return (
    <MenubarPrimitive.CheckboxItem
      data-slot="menubar-checkbox-item"
      className={cn(
        "focus:bg-accent focus:text-accent-foreground relative flex cursor-default items-center gap-2 rounded-xs py-1.5 pr-2 pl-8 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      checked={checked}
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <MenubarPrimitive.ItemIndicator>
          <CheckIcon className="size-4" />
        </MenubarPrimitive.ItemIndicator>
      </span>
      {children}
    </MenubarPrimitive.CheckboxItem>
  )
}

function MenubarRadioItem({
  className,
  children,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.RadioItem>) {
  return (
    <MenubarPrimitive.RadioItem
      data-slot="menubar-radio-item"
      className={cn(
        "focus:bg-accent focus:text-accent-foreground relative flex cursor-default items-center gap-2 rounded-xs py-1.5 pr-2 pl-8 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      {...props}
    >
      <span className="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
        <MenubarPrimitive.ItemIndicator>
          <CircleIcon className="size-2 fill-current" />
        </MenubarPrimitive.ItemIndicator>
      </span>
      {children}
    </MenubarPrimitive.RadioItem>
  )
}

function MenubarLabel({
  className,
  inset,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Label> & {
  inset?: boolean
}) {
  return (
    <MenubarPrimitive.Label
      data-slot="menubar-label"
      data-inset={inset}
      className={cn(
        "px-2 py-1.5 text-sm font-medium data-[inset]:pl-8",
        className
      )}
      {...props}
    />
  )
}

function MenubarSeparator({
  className,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Separator>) {
  return (
    <MenubarPrimitive.Separator
      data-slot="menubar-separator"
      className={cn("bg-border -mx-1 my-1 h-px", className)}
      {...props}
    />
  )
}

function MenubarShortcut({
  className,
  ...props
}: React.ComponentProps<"span">) {
  return (
    <span
      data-slot="menubar-shortcut"
      className={cn(
        "text-muted-foreground ml-auto text-xs tracking-widest",
        className
      )}
      {...props}
    />
  )
}

function MenubarSub({
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.Sub>) {
  return <MenubarPrimitive.Sub data-slot="menubar-sub" {...props} />
}

function MenubarSubTrigger({
  className,
  inset,
  children,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.SubTrigger> & {
  inset?: boolean
}) {
  return (
    <MenubarPrimitive.SubTrigger
      data-slot="menubar-sub-trigger"
      data-inset={inset}
      className={cn(
        "focus:bg-accent focus:text-accent-foreground data-[state=open]:bg-accent data-[state=open]:text-accent-foreground flex cursor-default items-center rounded-sm px-2 py-1.5 text-sm outline-none select-none data-[inset]:pl-8",
        className
      )}
      {...props}
    >
      {children}
      <ChevronRightIcon className="ml-auto h-4 w-4" />
    </MenubarPrimitive.SubTrigger>
  )
}

function MenubarSubContent({
  className,
  ...props
}: React.ComponentProps<typeof MenubarPrimitive.SubContent>) {
  return (
    <MenubarPrimitive.SubContent
      data-slot="menubar-sub-content"
      className={cn(
        "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 min-w-[8rem] origin-(--radix-menubar-content-transform-origin) overflow-hidden rounded-md border p-1 shadow-lg",
        className
      )}
      {...props}
    />
  )
}

export {
  Menubar,
  MenubarPortal,
  MenubarMenu,
  MenubarTrigger,
  MenubarContent,
  MenubarGroup,
  MenubarSeparator,
  MenubarLabel,
  MenubarItem,
  MenubarShortcut,
  MenubarCheckboxItem,
  MenubarRadioGroup,
  MenubarRadioItem,
  MenubarSub,
  MenubarSubTrigger,
  MenubarSubContent,
}



================================================
FILE: app/components/ui/modal.tsx
================================================
import React from "react";

export function Modal({ open, onClose, children, title }: { open: boolean; onClose: () => void; children: React.ReactNode; title?: string }) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-[9998]">
      <div className="absolute inset-0 bg-background/70 backdrop-blur-sm" onClick={onClose} />
      <div className="absolute inset-0 flex items-center justify-center p-4">
        <div className="w-full max-w-sm rounded-md border border-border bg-background shadow-xl">
          {title ? (
            <div className="px-4 py-2 border-b border-border/50 text-sm font-medium">{title}</div>
          ) : null}
          <div className="p-4">{children}</div>
        </div>
      </div>
    </div>
  );
}





================================================
FILE: app/components/ui/Navbar.tsx
================================================
import { Link } from "react-router";
import { useEffect, useState } from "react";
import { Button } from "~/components/ui/button";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { Github, Twitter } from "lucide-react";
import { TbBrandDiscord } from "react-icons/tb";
import { motion, AnimatePresence } from "framer-motion";

interface NavbarProps {
  showBrand?: boolean;
}

export function Navbar({ showBrand = true }: NavbarProps) {
  const [spin, setSpin] = useState(false);
  const [gitHubStars, setGitHubStars] = useState<number>(0);

  useEffect(() => {
    const fetchGitHubStars = async () => {
      try {
        const res = await fetch(
          "https://api.github.com/repos/trykimu/videoeditor"
        );
        const data = await res.json();
        setGitHubStars(data.stargazers_count || 0);
      } catch (error) {
        console.log("Failed to fetch GitHub stars");
      }
    };

    fetchGitHubStars();
  }, []);

  return (
    <header className="fixed top-0 left-0 right-0 z-50">
      <div className="max-w-7xl mx-auto px-6 py-3">
        <div className="rounded-xl border-2 border-border/30 bg-background/60 backdrop-blur supports-[backdrop-filter]:bg-background/40 shadow-[0_8px_30px_rgba(0,0,0,0.15)] px-3 py-2 flex items-center justify-between">
          {/* Fixed width container for brand to prevent layout shift */}
          <div className="w-32 flex items-center justify-start">
            <Link to="/" className="flex items-center gap-3">
              <AnimatePresence mode="wait">
                {showBrand && (
                  <motion.button
                    key="logo"
                    onClick={() => setSpin(true)}
                    className="cursor-pointer"
                    onAnimationEnd={() => setSpin(false)}
                    initial={{ opacity: 0, scale: 0.8, x: -10 }}
                    animate={{ opacity: 1, scale: 1, x: 0 }}
                    exit={{ opacity: 0, scale: 0.8, x: -10 }}
                    transition={{
                      duration: 0.4,
                      ease: [0.4, 0.0, 0.2, 1],
                      delay: 0.1,
                    }}
                  >
                    <KimuLogo
                      className={`w-6 h-6 text-foreground ${
                        spin ? "animate-spin" : ""
                      }`}
                    />
                  </motion.button>
                )}
              </AnimatePresence>
              <AnimatePresence mode="wait">
                {showBrand && (
                  <motion.span
                    key="text"
                    className="font-semibold tracking-tight"
                    initial={{ opacity: 0, x: -5 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -5 }}
                    transition={{
                      duration: 0.4,
                      ease: [0.4, 0.0, 0.2, 1],
                      delay: 0.2,
                    }}
                  >
                    Kimu
                  </motion.span>
                )}
              </AnimatePresence>
            </Link>
          </div>

          {/* Center navigation - will stay fixed */}
          <nav className="hidden md:flex items-center gap-5 text-sm text-muted-foreground">
            <a
              href="http://deepwiki.com/trykimu/videoeditor/"
              target="_blank"
              rel="noreferrer"
              className="hover:text-foreground transition-colors"
            >
              Docs
            </a>
            <Link
              to="/privacy"
              className="hover:text-foreground transition-colors"
            >
              Privacy
            </Link>
            <Link
              to="/marketplace"
              className="hover:text-foreground transition-colors"
            >
              Marketplace
            </Link>
          </nav>

          {/* Right side actions */}
          <div className="flex items-center gap-3">
            <a
              href="https://github.com/trykimu/videoeditor"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 rounded-lg border border-border/30 bg-muted/20 px-2 py-1 text-xs text-muted-foreground hover:text-foreground hover:bg-muted/30 transition-colors"
            >
              <Github className="w-4 h-4" />
              <span>{gitHubStars}</span>
            </a>
            <a
              href="https://twitter.com/trykimu"
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground transition-colors"
            >
              <Twitter className="w-4 h-4" />
            </a>
            <a
              href="https://discord.gg/24Mt5DGcbx"
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground transition-colors"
              title="Join our Discord"
            >
              <TbBrandDiscord className="w-4 h-4" />
            </a>
            <Link to="/login">
              <Button
                size="sm"
                className="h-8 px-3 bg-foreground text-background hover:bg-foreground/90"
              >
                Get Started
              </Button>
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}



================================================
FILE: app/components/ui/ProfileMenu.tsx
================================================
import React from "react";
import { useTheme } from "next-themes";
import { Sun, Moon, LogOut, Star, HardDrive } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "~/components/ui/dropdown-menu";
import { Progress } from "~/components/ui/progress";

type UserLike = {
  name?: string | null;
  email?: string | null;
  image?: string | null;
};

export function ProfileMenu({
  user,
  starCount,
  onSignOut,
}: {
  user: UserLike;
  starCount: number | null;
  onSignOut: () => void;
}) {
  const { theme, setTheme } = useTheme();
  const [usedBytes, setUsedBytes] = React.useState<number | null>(null);
  const [limitBytes, setLimitBytes] = React.useState<number>(2 * 1024 * 1024 * 1024);

  React.useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const res = await fetch("/api/storage", { credentials: "include" });
        if (!res.ok) return;
        const j = await res.json();
        if (!cancelled) {
          const u = Number(j?.usedBytes || 0);
          const l = Number(j?.limitBytes || limitBytes);
          setUsedBytes(Number.isFinite(u) ? u : 0);
          setLimitBytes(Number.isFinite(l) ? l : 2 * 1024 * 1024 * 1024);
        }
      } catch {
        console.error("Storage fetch failed");
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [limitBytes]);

  function formatBytes(bytes: number): string {
    if (!Number.isFinite(bytes) || bytes <= 0) return "0 B";
    const units = ["B", "KB", "MB", "GB", "TB"] as const;
    const i = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
    const val = bytes / Math.pow(1024, i);
    return `${val >= 100 ? Math.round(val) : val.toFixed(1)} ${units[i]}`;
  }

  const GitHubIcon = ({ className }: { className?: string }) => (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor">
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
  );

  const DiscordIcon = ({ className }: { className?: string }) => (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor">
      <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515a.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0a12.64 12.64 0 0 0-.617-1.25a.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057a19.9 19.9 0 0 0 5.993 3.03a.078.078 0 0 0 .084-.028a14.09 14.09 0 0 0 1.226-1.994a.076.076 0 0 0-.041-.106a13.107 13.107 0 0 1-1.872-.892a.077.077 0 0 1-.008-.128a10.2 10.2 0 0 0 .372-.292a.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127a12.299 12.299 0 0 1-1.873.892a.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028a19.839 19.839 0 0 0 6.002-3.03a.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.956-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.955-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.946 2.418-2.157 2.418z" />
    </svg>
  );

  const XIcon = ({ className }: { className?: string }) => (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor">
      <path d="M18.244 2H21l-6.6 7.548L22 22h-6.8l-4.4-5.8L5.6 22H3l7.2-8.24L2 2h6.8l4 5.4L18.244 2Zm-1.2 18h1.88L8.08 4H6.2l10.844 16Z" />
    </svg>
  );

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button className="h-6 w-6 rounded-full overflow-hidden border border-border/60 focus:outline-none focus:ring-2 focus:ring-primary/30 relative ml-1">
          <div className="absolute inset-0 bg-muted flex items-center justify-center text-[10px] font-medium">
            {(user.name ?? user.email ?? "").slice(0, 1).toUpperCase()}
          </div>
          {user.image && (
            <img
              src={user.image}
              alt={user.name ?? user.email ?? "Profile"}
              className="h-full w-full object-cover relative z-10"
              onError={(e) => {
                (e.currentTarget as HTMLImageElement).style.display = "none";
              }}
              referrerPolicy="no-referrer"
            />
          )}
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="min-w-[220px]">
        <div className="px-2 py-1.5 text-xs text-muted-foreground">{user.name || user.email || "Signed in"}</div>
        <DropdownMenuItem asChild>
          <a href="/profile" className="text-xs">
            View profile
          </a>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuLabel className="text-[11px] text-muted-foreground">Appearance</DropdownMenuLabel>
        <DropdownMenuItem asChild>
          <button
            className="w-full flex items-center gap-2 text-xs"
            onClick={() => setTheme(theme === "dark" ? "light" : "dark")}>
            {theme === "dark" ? <Sun className="h-3.5 w-3.5" /> : <Moon className="h-3.5 w-3.5" />}
            Switch theme
          </button>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuLabel className="text-[11px] text-muted-foreground">Socials</DropdownMenuLabel>
        <div className="px-0 pb-2">
          <div className="flex items-center justify-center gap-1">
            <DropdownMenuItem asChild className="p-0">
              <a
                href="https://github.com/trykimu/videoeditor"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center h-8 rounded-md border border-border/40 px-3 hover:bg-accent/30 focus:bg-accent/30 focus:outline-none transition-colors"
                title="GitHub">
                <span className="inline-flex items-center justify-center gap-1 leading-none">
                  <GitHubIcon className="h-3 w-3 shrink-0" />
                  <Star className="h-2.5 w-2.5 text-muted-foreground shrink-0" />
                  <span className="font-mono text-[10px] text-muted-foreground leading-none">
                    {starCount !== null ? starCount.toLocaleString() : "..."}
                  </span>
                </span>
              </a>
            </DropdownMenuItem>
            <DropdownMenuItem asChild className="p-0">
              <a
                href="https://discord.gg/24Mt5DGcbx"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center w-14 h-8 rounded-md border border-border/40 px-2 hover:bg-accent/30 focus:bg-accent/30 focus:outline-none transition-colors"
                title="Discord">
                <DiscordIcon className="h-3.5 w-3.5" />
              </a>
            </DropdownMenuItem>
            <DropdownMenuItem asChild className="p-0">
              <a
                href="https://x.com/trykimu"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center w-14 h-8 rounded-md border border-border/40 px-2 hover:bg-accent/30 focus:bg-accent/30 focus:outline-none transition-colors"
                title="X (Twitter)">
                <XIcon className="h-3.5 w-3.5" />
              </a>
            </DropdownMenuItem>
          </div>
        </div>
        <DropdownMenuSeparator />
        <DropdownMenuLabel className="text-[11px] text-muted-foreground">Cloud Storage</DropdownMenuLabel>
        <div className="px-2 pb-2 flex flex-col gap-1.5">
          <div className="flex items-center justify-between text-[10px] text-muted-foreground">
            <span className="inline-flex items-center gap-1">
              <HardDrive className="h-3 w-3" />
              Storage
            </span>
            <span className="font-mono">
              {usedBytes === null ? "..." : `${formatBytes(usedBytes)} / ${formatBytes(limitBytes)}`}
            </span>
          </div>
          {
            <Progress
              // @ts-ignore radix root value
              value={
                usedBytes !== null && limitBytes > 0 ? Math.min(100, Math.max(0, (usedBytes / limitBytes) * 100)) : 0
              }
            />
          }
        </div>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={() => {
            onSignOut();
            setTimeout(() => {
              // Use navigation API or router instead of direct href assignment
              window.location.assign("/");
            }, 100);
          }}
          variant="destructive">
          <LogOut className="h-4 w-4" />
          <span className="text-xs font-medium">Sign out</span>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}



================================================
FILE: app/components/ui/progress.tsx
================================================
"use client"

import * as React from "react"
import * as ProgressPrimitive from "@radix-ui/react-progress"

import { cn } from "~/lib/utils"

function Progress({
  className,
  value,
  ...props
}: React.ComponentProps<typeof ProgressPrimitive.Root>) {
  return (
    <ProgressPrimitive.Root
      data-slot="progress"
      className={cn(
        "bg-primary/20 relative h-2 w-full overflow-hidden rounded-full",
        className
      )}
      {...props}
    >
      <ProgressPrimitive.Indicator
        data-slot="progress-indicator"
        className="bg-primary h-full w-full flex-1 transition-all"
        style={{ transform: `translateX(-${100 - (value || 0)}%)` }}
      />
    </ProgressPrimitive.Root>
  )
}

export { Progress }



================================================
FILE: app/components/ui/resizable.tsx
================================================
import * as React from "react"
import { GripVerticalIcon } from "lucide-react"
import * as ResizablePrimitive from "react-resizable-panels"

import { cn } from "~/lib/utils"

function ResizablePanelGroup({
  className,
  ...props
}: React.ComponentProps<typeof ResizablePrimitive.PanelGroup>) {
  return (
    <ResizablePrimitive.PanelGroup
      data-slot="resizable-panel-group"
      className={cn(
        "flex h-full w-full data-[panel-group-direction=vertical]:flex-col",
        className
      )}
      {...props}
    />
  )
}

function ResizablePanel({
  ...props
}: React.ComponentProps<typeof ResizablePrimitive.Panel>) {
  return <ResizablePrimitive.Panel data-slot="resizable-panel" {...props} />
}

function ResizableHandle({
  withHandle,
  className,
  ...props
}: React.ComponentProps<typeof ResizablePrimitive.PanelResizeHandle> & {
  withHandle?: boolean
}) {
  return (
    <ResizablePrimitive.PanelResizeHandle
      data-slot="resizable-handle"
      className={cn(
        "bg-border focus-visible:ring-ring relative flex w-px items-center justify-center after:absolute after:inset-y-0 after:left-1/2 after:w-1 after:-translate-x-1/2 focus-visible:ring-1 focus-visible:ring-offset-1 focus-visible:outline-hidden data-[panel-group-direction=vertical]:h-px data-[panel-group-direction=vertical]:w-full data-[panel-group-direction=vertical]:after:left-0 data-[panel-group-direction=vertical]:after:h-1 data-[panel-group-direction=vertical]:after:w-full data-[panel-group-direction=vertical]:after:translate-x-0 data-[panel-group-direction=vertical]:after:-translate-y-1/2 [&[data-panel-group-direction=vertical]>div]:rotate-90",
        className
      )}
      {...props}
    >
      {withHandle && (
        <div className="bg-border z-10 flex h-4 w-3 items-center justify-center rounded-xs border">
          <GripVerticalIcon className="size-2.5" />
        </div>
      )}
    </ResizablePrimitive.PanelResizeHandle>
  )
}

export { ResizablePanelGroup, ResizablePanel, ResizableHandle }



================================================
FILE: app/components/ui/scroll-area.tsx
================================================
import * as React from "react"
import * as ScrollAreaPrimitive from "@radix-ui/react-scroll-area"

import { cn } from "~/lib/utils"

function ScrollArea({
  className,
  children,
  ...props
}: React.ComponentProps<typeof ScrollAreaPrimitive.Root>) {
  return (
    <ScrollAreaPrimitive.Root
      data-slot="scroll-area"
      className={cn("relative", className)}
      {...props}
    >
      <ScrollAreaPrimitive.Viewport
        data-slot="scroll-area-viewport"
        className="focus-visible:ring-ring/50 size-full rounded-[inherit] transition-[color,box-shadow] outline-none focus-visible:ring-[3px] focus-visible:outline-1"
      >
        {children}
      </ScrollAreaPrimitive.Viewport>
      <ScrollBar />
      <ScrollAreaPrimitive.Corner />
    </ScrollAreaPrimitive.Root>
  )
}

function ScrollBar({
  className,
  orientation = "vertical",
  ...props
}: React.ComponentProps<typeof ScrollAreaPrimitive.ScrollAreaScrollbar>) {
  return (
    <ScrollAreaPrimitive.ScrollAreaScrollbar
      data-slot="scroll-area-scrollbar"
      orientation={orientation}
      className={cn(
        "flex touch-none p-px transition-colors select-none",
        orientation === "vertical" &&
          "h-full w-2.5 border-l border-l-transparent",
        orientation === "horizontal" &&
          "h-2.5 flex-col border-t border-t-transparent",
        className
      )}
      {...props}
    >
      <ScrollAreaPrimitive.ScrollAreaThumb
        data-slot="scroll-area-thumb"
        className="bg-border relative flex-1 rounded-full"
      />
    </ScrollAreaPrimitive.ScrollAreaScrollbar>
  )
}

export { ScrollArea, ScrollBar }



================================================
FILE: app/components/ui/select.tsx
================================================
import * as React from "react"
import * as SelectPrimitive from "@radix-ui/react-select"
import { CheckIcon, ChevronDownIcon, ChevronUpIcon } from "lucide-react"

import { cn } from "~/lib/utils"

function Select({
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Root>) {
  return <SelectPrimitive.Root data-slot="select" {...props} />
}

function SelectGroup({
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Group>) {
  return <SelectPrimitive.Group data-slot="select-group" {...props} />
}

function SelectValue({
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Value>) {
  return <SelectPrimitive.Value data-slot="select-value" {...props} />
}

function SelectTrigger({
  className,
  size = "default",
  children,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Trigger> & {
  size?: "sm" | "default"
}) {
  return (
    <SelectPrimitive.Trigger
      data-slot="select-trigger"
      data-size={size}
      className={cn(
        "border-input data-[placeholder]:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 dark:hover:bg-input/50 flex w-fit items-center justify-between gap-2 rounded-md border bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-9 data-[size=sm]:h-8 *:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-2 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      {...props}
    >
      {children}
      <SelectPrimitive.Icon asChild>
        <ChevronDownIcon className="size-4 opacity-50" />
      </SelectPrimitive.Icon>
    </SelectPrimitive.Trigger>
  )
}

function SelectContent({
  className,
  children,
  position = "popper",
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Content>) {
  return (
    <SelectPrimitive.Portal>
      <SelectPrimitive.Content
        data-slot="select-content"
        className={cn(
          "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 relative z-50 max-h-(--radix-select-content-available-height) min-w-[8rem] origin-(--radix-select-content-transform-origin) overflow-x-hidden overflow-y-auto rounded-md border shadow-md",
          position === "popper" &&
            "data-[side=bottom]:translate-y-1 data-[side=left]:-translate-x-1 data-[side=right]:translate-x-1 data-[side=top]:-translate-y-1",
          className
        )}
        position={position}
        {...props}
      >
        <SelectScrollUpButton />
        <SelectPrimitive.Viewport
          className={cn(
            "p-1",
            position === "popper" &&
              "h-[var(--radix-select-trigger-height)] w-full min-w-[var(--radix-select-trigger-width)] scroll-my-1"
          )}
        >
          {children}
        </SelectPrimitive.Viewport>
        <SelectScrollDownButton />
      </SelectPrimitive.Content>
    </SelectPrimitive.Portal>
  )
}

function SelectLabel({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Label>) {
  return (
    <SelectPrimitive.Label
      data-slot="select-label"
      className={cn("text-muted-foreground px-2 py-1.5 text-xs", className)}
      {...props}
    />
  )
}

function SelectItem({
  className,
  children,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Item>) {
  return (
    <SelectPrimitive.Item
      data-slot="select-item"
      className={cn(
        "focus:bg-accent focus:text-accent-foreground [&_svg:not([class*='text-'])]:text-muted-foreground relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 *:[span]:last:flex *:[span]:last:items-center *:[span]:last:gap-2",
        className
      )}
      {...props}
    >
      <span className="absolute right-2 flex size-3.5 items-center justify-center">
        <SelectPrimitive.ItemIndicator>
          <CheckIcon className="size-4" />
        </SelectPrimitive.ItemIndicator>
      </span>
      <SelectPrimitive.ItemText>{children}</SelectPrimitive.ItemText>
    </SelectPrimitive.Item>
  )
}

function SelectSeparator({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Separator>) {
  return (
    <SelectPrimitive.Separator
      data-slot="select-separator"
      className={cn("bg-border pointer-events-none -mx-1 my-1 h-px", className)}
      {...props}
    />
  )
}

function SelectScrollUpButton({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.ScrollUpButton>) {
  return (
    <SelectPrimitive.ScrollUpButton
      data-slot="select-scroll-up-button"
      className={cn(
        "flex cursor-default items-center justify-center py-1",
        className
      )}
      {...props}
    >
      <ChevronUpIcon className="size-4" />
    </SelectPrimitive.ScrollUpButton>
  )
}

function SelectScrollDownButton({
  className,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.ScrollDownButton>) {
  return (
    <SelectPrimitive.ScrollDownButton
      data-slot="select-scroll-down-button"
      className={cn(
        "flex cursor-default items-center justify-center py-1",
        className
      )}
      {...props}
    >
      <ChevronDownIcon className="size-4" />
    </SelectPrimitive.ScrollDownButton>
  )
}

export {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectScrollDownButton,
  SelectScrollUpButton,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
}



================================================
FILE: app/components/ui/separator.tsx
================================================
"use client"

import * as React from "react"
import * as SeparatorPrimitive from "@radix-ui/react-separator"

import { cn } from "~/lib/utils"

function Separator({
  className,
  orientation = "horizontal",
  decorative = true,
  ...props
}: React.ComponentProps<typeof SeparatorPrimitive.Root>) {
  return (
    <SeparatorPrimitive.Root
      data-slot="separator"
      decorative={decorative}
      orientation={orientation}
      className={cn(
        "bg-border shrink-0 data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px",
        className
      )}
      {...props}
    />
  )
}

export { Separator }



================================================
FILE: app/components/ui/skeleton.tsx
================================================
import { cn } from "~/lib/utils"

function Skeleton({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="skeleton"
      className={cn("bg-accent animate-pulse rounded-md", className)}
      {...props}
    />
  )
}

export { Skeleton }



================================================
FILE: app/components/ui/sonner.tsx
================================================
import { useTheme } from "next-themes";
import { Toaster as Sonner, type ToasterProps } from "sonner";

const Toaster = ({ ...props }: ToasterProps) => {
  const { theme = "system" } = useTheme();

  return (
    <Sonner
      theme={theme as ToasterProps["theme"]}
      className="toaster group"
      position="bottom-right"
      toastOptions={{
        style: {
          fontSize: "13px",
          padding: "12px 16px",
          borderRadius: "6px",
          border: "1px solid rgb(var(--border))",
          backgroundColor: "rgb(var(--background))",
          color: "rgb(var(--foreground))",
          minWidth: 300,
          maxWidth: 380,
        },
        className: "shadow-lg",
      }}
      {...props}
    />
  );
};

export { Toaster };



================================================
FILE: app/components/ui/switch.tsx
================================================
"use client";

import * as React from "react";
import * as SwitchPrimitive from "@radix-ui/react-switch";

import { cn } from "~/lib/utils";

function Switch({
  className,
  ...props
}: React.ComponentProps<typeof SwitchPrimitive.Root>) {
  return (
    <SwitchPrimitive.Root
      data-slot="switch"
      className={cn(
        "peer data-[state=checked]:bg-primary data-[state=unchecked]:bg-input focus-visible:border-ring focus-visible:ring-ring/50 dark:data-[state=unchecked]:bg-input/80 inline-flex h-[1.15rem] w-8 shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      {...props}
    >
      <SwitchPrimitive.Thumb
        data-slot="switch-thumb"
        className={cn(
          "bg-background dark:data-[state=unchecked]:bg-foreground dark:data-[state=checked]:bg-primary-foreground pointer-events-none block size-4 rounded-full ring-0 transition-transform data-[state=checked]:translate-x-[calc(100%-2px)] data-[state=unchecked]:translate-x-0"
        )}
      />
    </SwitchPrimitive.Root>
  );
}

export { Switch };



================================================
FILE: app/components/ui/tabs.tsx
================================================
import * as React from "react";
import * as TabsPrimitive from "@radix-ui/react-tabs";

import { cn } from "~/lib/utils";

function Tabs({
  className,
  ...props
}: React.ComponentProps<typeof TabsPrimitive.Root>) {
  return (
    <TabsPrimitive.Root
      data-slot="tabs"
      className={cn("flex flex-col gap-2", className)}
      {...props}
    />
  );
}

function TabsList({
  className,
  ...props
}: React.ComponentProps<typeof TabsPrimitive.List>) {
  return (
    <TabsPrimitive.List
      data-slot="tabs-list"
      className={cn(
        "bg-muted text-muted-foreground inline-flex h-9 w-fit items-center justify-center rounded-lg p-[3px]",
        className
      )}
      {...props}
    />
  );
}

function TabsTrigger({
  className,
  ...props
}: React.ComponentProps<typeof TabsPrimitive.Trigger>) {
  return (
    <TabsPrimitive.Trigger
      data-slot="tabs-trigger"
      className={cn(
        "data-[state=active]:bg-background dark:data-[state=active]:text-foreground focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:outline-ring dark:data-[state=active]:border-input dark:data-[state=active]:bg-input/30 text-foreground dark:text-muted-foreground inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap transition-[color,box-shadow] focus-visible:ring-[3px] focus-visible:outline-1 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:shadow-sm [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
        className
      )}
      {...props}
    />
  );
}

function TabsContent({
  className,
  ...props
}: React.ComponentProps<typeof TabsPrimitive.Content>) {
  return (
    <TabsPrimitive.Content
      data-slot="tabs-content"
      className={cn("flex-1 outline-none", className)}
      {...props}
    />
  );
}

export { Tabs, TabsList, TabsTrigger, TabsContent };



================================================
FILE: app/components/ui/text-hover-effect.tsx
================================================
import React, { useRef, useEffect, useState } from "react";
import { motion, type TargetAndTransition } from "framer-motion";

export const TextHoverEffect = ({
  text,
  duration,
}: {
  text: string;
  duration?: number;
  automatic?: boolean;
}) => {
  const svgRef = useRef<SVGSVGElement>(null);
  const [cursor, setCursor] = useState({ x: 0, y: 0 });
  const [hovered, setHovered] = useState(false);
  const [maskPosition, setMaskPosition] = useState({ cx: "50%", cy: "50%" });

  useEffect(() => {
    if (svgRef.current && cursor.x !== null && cursor.y !== null) {
      const svgRect = svgRef.current.getBoundingClientRect();
      const cxPercentage = ((cursor.x - svgRect.left) / svgRect.width) * 100;
      const cyPercentage = ((cursor.y - svgRect.top) / svgRect.height) * 100;
      setMaskPosition({
        cx: `${cxPercentage}%`,
        cy: `${cyPercentage}%`,
      });
    }
  }, [cursor]);

  return (
    <svg
      ref={svgRef}
      width="100%"
      height="100%"
      viewBox="0 0 300 100"
      xmlns="http://www.w3.org/2000/svg"
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onMouseMove={(e) => setCursor({ x: e.clientX, y: e.clientY })}
      className="select-none"
    >
      <defs>
        <linearGradient
          id="textGradient"
          gradientUnits="userSpaceOnUse"
          cx="50%"
          cy="50%"
          r="25%"
        >
          {hovered && (
            <>
              <stop offset="0%" stopColor="#eab308" />
              <stop offset="25%" stopColor="#ef4444" />
              <stop offset="50%" stopColor="#3b82f6" />
              <stop offset="75%" stopColor="#06b6d4" />
              <stop offset="100%" stopColor="#8b5cf6" />
            </>
          )}
        </linearGradient>

        <motion.radialGradient
          id="revealMask"
          gradientUnits="userSpaceOnUse"
          r="20%"
          initial={{ cx: "50%", cy: "50%" }}
          animate={maskPosition as TargetAndTransition}
          transition={{ duration: duration ?? 0, ease: "easeOut" }}
        >
          <stop offset="0%" stopColor="white" />
          <stop offset="100%" stopColor="black" />
        </motion.radialGradient>
        <mask id="textMask">
          <rect
            x="0"
            y="0"
            width="100%"
            height="100%"
            fill="url(#revealMask)"
          />
        </mask>
      </defs>
      <text
        x="50%"
        y="50%"
        textAnchor="middle"
        dominantBaseline="middle"
        strokeWidth="0.3"
        className="fill-transparent stroke-neutral-200 font-[helvetica] text-7xl font-bold dark:stroke-neutral-800"
        style={{ opacity: hovered ? 0.7 : 0 }}
      >
        {text}
      </text>
      <motion.text
        x="50%"
        y="50%"
        textAnchor="middle"
        dominantBaseline="middle"
        strokeWidth="0.3"
        className="fill-transparent stroke-neutral-200 font-[helvetica] text-7xl font-bold dark:stroke-neutral-800"
        initial={{ strokeDashoffset: 1000, strokeDasharray: 1000 }}
        animate={{ strokeDashoffset: 0, strokeDasharray: 1000 }}
        transition={{ duration: 4, ease: "easeInOut" }}
      >
        {text}
      </motion.text>
      <text
        x="50%"
        y="50%"
        textAnchor="middle"
        dominantBaseline="middle"
        stroke="url(#textGradient)"
        strokeWidth="0.3"
        mask="url(#textMask)"
        className="fill-transparent font-[helvetica] text-7xl font-bold"
      >
        {text}
      </text>
    </svg>
  );
};



================================================
FILE: app/components/ui/ThemeProvider.tsx
================================================
import * as React from "react";
import {
  ThemeProvider as NextThemesProvider,
  type ThemeProviderProps,
} from "next-themes";

// Enhanced ThemeProvider for clean monochrome theming
export function ThemeProvider({
  children,
  ...props
}: {
  children: React.ReactNode;
}) {
  return (
    <NextThemesProvider
      attribute="class"
      defaultTheme="system"
      enableSystem={true}
      themes={["light", "dark"]}
      value={{
        light: "light",
        dark: "dark",
      }}
      {...props}
    >
      {children}
    </NextThemesProvider>
  );
}

export function useTheme() {
  const context = React.useContext(
    NextThemesProvider as React.Context<ThemeProviderProps>
  );
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}



================================================
FILE: app/components/ui/tooltip.tsx
================================================
import * as React from "react";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";

import { cn } from "~/lib/utils";

function TooltipProvider({
  delayDuration = 0,
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Provider>) {
  return (
    <TooltipPrimitive.Provider
      data-slot="tooltip-provider"
      delayDuration={delayDuration}
      {...props}
    />
  );
}

function Tooltip({
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Root>) {
  return (
    <TooltipProvider>
      <TooltipPrimitive.Root data-slot="tooltip" {...props} />
    </TooltipProvider>
  );
}

function TooltipTrigger({
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Trigger>) {
  return <TooltipPrimitive.Trigger data-slot="tooltip-trigger" {...props} />;
}

function TooltipContent({
  className,
  sideOffset = 0,
  children,
  ...props
}: React.ComponentProps<typeof TooltipPrimitive.Content>) {
  return (
    <TooltipPrimitive.Portal>
      <TooltipPrimitive.Content
        data-slot="tooltip-content"
        sideOffset={sideOffset}
        className={cn(
          "bg-primary text-primary-foreground animate-in fade-in-0 zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 w-fit origin-(--radix-tooltip-content-transform-origin) rounded-md px-3 py-1.5 text-xs text-balance",
          className
        )}
        {...props}
      >
        {children}
        <TooltipPrimitive.Arrow className="bg-primary fill-primary z-50 size-2.5 translate-y-[calc(-50%_-_2px)] rotate-45 rounded-[2px]" />
      </TooltipPrimitive.Content>
    </TooltipPrimitive.Portal>
  );
}

export { Tooltip, TooltipTrigger, TooltipContent, TooltipProvider };



================================================
FILE: app/components/ui/video-controls.tsx
================================================
import type { PlayerRef } from "@remotion/player";
import React, { useCallback, useEffect, useState } from "react";
import { Volume2, VolumeX, Maximize, Minimize } from "lucide-react";
import { Button } from "~/components/ui/button";

// Mute Button Component
export const MuteButton: React.FC<{
  playerRef: React.RefObject<PlayerRef | null>;
}> = ({ playerRef }) => {
  const [muted, setMuted] = useState(playerRef.current?.isMuted() ?? false);

  const onClick = useCallback(() => {
    if (!playerRef.current) {
      return;
    }

    if (playerRef.current.isMuted()) {
      playerRef.current.unmute();
    } else {
      playerRef.current.mute();
    }
  }, [playerRef]);

  useEffect(() => {
    const { current } = playerRef;
    if (!current) {
      return;
    }

    const onMuteChange = () => {
      setMuted(current.isMuted());
    };

    current.addEventListener("mutechange", onMuteChange);
    return () => {
      current.removeEventListener("mutechange", onMuteChange);
    };
  }, [playerRef]);

  return (
    <Button
      variant="ghost"
      size="sm"
      onClick={onClick}
      className="h-6 w-6 p-0"
      title={muted ? "Unmute" : "Mute"}
    >
      {muted ? (
        <VolumeX className="h-3 w-3" />
      ) : (
        <Volume2 className="h-3 w-3" />
      )}
    </Button>
  );
};

// Fullscreen Button Component
export const FullscreenButton: React.FC<{
  playerRef: React.RefObject<PlayerRef | null>;
}> = ({ playerRef }) => {
  const [supportsFullscreen, setSupportsFullscreen] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);

  useEffect(() => {
    const { current } = playerRef;

    if (!current) {
      return;
    }

    const onFullscreenChange = () => {
      setIsFullscreen(document.fullscreenElement !== null);
    };

    current.addEventListener("fullscreenchange", onFullscreenChange);

    return () => {
      current.removeEventListener("fullscreenchange", onFullscreenChange);
    };
  }, [playerRef]);

  useEffect(() => {
    // Must be handled client-side to avoid SSR hydration mismatch
    setSupportsFullscreen(
      (typeof document !== "undefined" &&
        (document.fullscreenEnabled ||
          // @ts-expect-error Types not defined
          document.webkitFullscreenEnabled)) ??
        false
    );
  }, []);

  const onClick = useCallback(() => {
    const { current } = playerRef;
    if (!current) {
      return;
    }

    if (isFullscreen) {
      current.exitFullscreen();
    } else {
      current.requestFullscreen();
    }
  }, [isFullscreen, playerRef]);

  if (!supportsFullscreen) {
    return null;
  }

  return (
    <Button
      variant="ghost"
      size="sm"
      onClick={onClick}
      className="h-6 w-6 p-0"
      title={isFullscreen ? "Exit Fullscreen" : "Enter Fullscreen"}
    >
      {isFullscreen ? (
        <Minimize className="h-3 w-3" />
      ) : (
        <Maximize className="h-3 w-3" />
      )}
    </Button>
  );
};



================================================
FILE: app/hooks/useAuth.ts
================================================
import { useEffect, useState } from "react";
import { apiUrl } from "~/utils/api";
import { authClient } from "~/lib/auth.client";
import { useNavigate } from "react-router";

interface AuthUser {
  id: string;
  email?: string | null;
  name?: string | null;
  image?: string | null;
}

interface AuthResponse {
  user?: {
    id?: string;
    userId?: string;
    email?: string;
    name?: string;
    image?: string;
    avatarUrl?: string;
  };
  data?: {
    user?: {
      id?: string;
      userId?: string;
      email?: string;
      name?: string;
      image?: string;
      avatarUrl?: string;
    };
  };
  session?: {
    user?: {
      id?: string;
      userId?: string;
      email?: string;
      name?: string;
      image?: string;
      avatarUrl?: string;
    };
    userId?: string;
  };
}

interface UseAuthResult {
  user: AuthUser | null;
  isLoading: boolean;
  isSigningIn: boolean;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
}

export function useAuth(): UseAuthResult {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    let isMounted = true;
    const extractUser = (data: unknown): AuthUser | null => {
      if (!data || typeof data !== "object") return null;

      const dataObj = data as AuthResponse;
      const raw = dataObj.user || dataObj?.data?.user || dataObj?.session?.user || null;

      if (raw) {
        return {
          id: String(raw.id ?? raw.userId ?? ""),
          email: raw.email ?? null,
          name: raw.name ?? null,
          image: raw.image ?? raw.avatarUrl ?? null,
        };
      }

      if (dataObj.session?.userId) {
        return { id: String(dataObj.session.userId) } as AuthUser;
      }

      return null;
    };

    // Fetch helpers return undefined on error (so we don't clear user)
    const fetchRestSession = async (): Promise<AuthUser | null | undefined> => {
      try {
        const sessionUrl = apiUrl("/api/auth/session", false, true);
        const res = await fetch(sessionUrl, {
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            Accept: "application/json",
          },
        });
        console.log("fetchRestSession");
        console.log("🔍 Fetching session from:", sessionUrl);
        console.log("🔍 API response status:", res.status);
        console.log("🔍 API response:", res);
        if (res.ok) {
          const json = await res.json();
          console.log("🔍 API response JSON:", json);
          return extractUser(json);
        }
        if (res.status === 404) return null;
        return undefined;
      } catch {
        return undefined;
      }
    };

    const fetchClientSession = async (): Promise<AuthUser | null | undefined> => {
      try {
        const result = await authClient.getSession?.();
        return extractUser(result);
      } catch {
        return undefined;
      }
    };

    const reconcileAndSet = (a: AuthUser | null | undefined, b: AuthUser | null | undefined) => {
      if (!isMounted) return;
      // Prefer any non-null user; only set null if both sources are null
      const next = a || b || (a === null && b === null ? null : user);
      if (next?.id !== user?.id || !!next !== !!user) {
        setUser(next ?? null);
      }
    };

    // Combined initial check
    const initialCheck = async () => {
      const [a, b] = await Promise.all([fetchRestSession(), fetchClientSession()]);
      reconcileAndSet(a, b);
      if (isMounted) setIsLoading(false);
    };

    // Check if we're returning from OAuth (look for common OAuth params)
    const urlParams = new URLSearchParams(window.location.search);
    const hasOAuthParams = urlParams.has("code") || urlParams.has("state") || urlParams.has("error");

    console.log("🔍 Current URL:", window.location.href);
    console.log("🔍 URL params:", Object.fromEntries(urlParams.entries()));
    console.log("🔍 Has OAuth params:", hasOAuthParams);

    if (hasOAuthParams) {
      console.log("🔄 OAuth callback detected, processing...");
      let attempts = 0;
      const checkWithRetry = async () => {
        attempts++;
        const [a, b] = await Promise.all([fetchRestSession(), fetchClientSession()]);
        reconcileAndSet(a, b);
        if (attempts < 5) {
          setTimeout(checkWithRetry, 800);
        }
      };
      setTimeout(checkWithRetry, 400);
      // Clean up URL by removing OAuth params after processing
      setTimeout(() => {
        const url = new URL(window.location.href);
        // Validate that we're only modifying search params and not changing origin
        if (url.origin === window.location.origin) {
          url.searchParams.delete("code");
          url.searchParams.delete("state");
          url.searchParams.delete("error");
          console.log("🧹 Cleaning up URL:", url.toString());
          window.history.replaceState({}, "", url.pathname + url.search + url.hash);
        }
      }, 5000);
      initialCheck();
    } else {
      console.log("🔍 No OAuth params, doing regular session check");
      initialCheck();
    }

    // Listen for auth state changes (when returning from OAuth)
    const handleFocus = () => {
      if (!isMounted) return;
      console.log("🔍 Window focused, checking session...");
      Promise.all([fetchRestSession(), fetchClientSession()]).then(([a, b]) => reconcileAndSet(a, b));
    };

    const handleVisibilityChange = () => {
      if (!isMounted || document.hidden) return;
      console.log("🔍 Page became visible, checking session...");
      setTimeout(() => {
        Promise.all([fetchRestSession(), fetchClientSession()]).then(([a, b]) => reconcileAndSet(a, b));
      }, 150);
    };

    window.addEventListener("focus", handleFocus);
    document.addEventListener("visibilitychange", handleVisibilityChange);

    // Removed periodic polling per request; rely on SSR + focus/visibility

    // Subscribe to Better Auth state changes (if available)
    let unsubscribe: (() => void) | undefined;
    if ("onAuthStateChange" in authClient && typeof authClient.onAuthStateChange === "function") {
      unsubscribe = authClient.onAuthStateChange((event: unknown) => {
        if (!isMounted) return;
        const nextUser = extractUser(event);
        if (typeof nextUser !== "undefined") setUser(nextUser);
      });
    }

    return () => {
      isMounted = false;
      window.removeEventListener("focus", handleFocus);
      document.removeEventListener("visibilitychange", handleVisibilityChange);
      // no interval to clear
      if (typeof unsubscribe === "function") unsubscribe();
    };
  }, [user]);

  const signInWithGoogle = async () => {
    setIsSigningIn(true);
    try {
      console.log("🔐 Starting Google sign-in...");
      // Try using Better Auth client's signIn method first
      if (authClient.signIn) {
        console.log("🔐 Using Better Auth client signIn");
        try {
          const result = await authClient.signIn.social({
            provider: "google",
            callbackURL: "/projects",
          });
          console.log("🔐 Sign-in response:", result);
          return;
        } catch (clientError) {
          console.log("🔐 Client signIn failed", clientError);
        }
      }

      // Fallback to REST API call with correct endpoint
      // console.log("🔐 Using REST API signIn");
      // const signInUrl = apiUrl("/api/auth/sign-in/social", false, true);
      // console.log("🔐 Sign-in URL:", signInUrl);
      // const response = await fetch(signInUrl, {
      //   method: "POST",
      //   headers: { "Content-Type": "application/json" },
      //   credentials: "include",
      //   // Let Better Auth handle callback at /api/auth/callback/google and then redirect back
      //   body: JSON.stringify({ provider: "google" })
      // });
      // if (response.ok) {
      //   const result = await response.json();
      //   console.log("🔐 Sign-in response:", result);
      //   if (result.url) {
      //     console.log("🔐 Redirecting to:", result.url);
      //     window.location.href = result.url;
      //   }
      // } else {
      //   console.error("❌ Sign-in failed:", response.status, await response.text());
      // }
    } catch (error) {
      console.error("❌ Sign in error:", error);
    } finally {
      setIsSigningIn(false);
    }
  };

  const signOut = async () => {
    try {
      console.log("🚪 Signing out...");

      // Try using Better Auth client's signOut method first
      if (authClient.signOut) {
        console.log("🔐 Using Better Auth client signOut");
        const result = await authClient.signOut();
        console.log("✅ Sign-out successful via client");
        setUser(null);
      } else {
        console.log("❌ Sign out failed");
      }

      // Fallback to REST API call with correct endpoint
      // console.log("🔐 Using REST API signOut");
      // const signOutUrl = apiUrl("/api/auth/sign-out", false, true);
      // console.log("URL:", signOutUrl);
      // const response = await fetch(signOutUrl, {
      //   method: "POST",
      //   credentials: "include",
      //   headers: {
      //     "Content-Type": "application/json",
      //   },
      // });

      // if (response.ok) {
      //   console.log("✅ Sign-out successful");
      //   setUser(null);
      // } else {
      //   console.log("❌ Sign out failed:", response.status, await response.text());
      // }
    } catch (error) {
      console.error("❌ Sign out error:", error);
    }
  };

  return { user, isLoading, isSigningIn, signInWithGoogle, signOut };
}



================================================
FILE: app/hooks/useMediaBin.ts
================================================
import { useState, useCallback, useEffect } from "react"
import axios from "axios"
import { type MediaBinItem, type ScrubberState } from "~/components/timeline/types"
import { generateUUID } from "~/utils/uuid"
import { apiUrl } from "~/utils/api"

// Delete media file from server
export const deleteMediaFile = async (
  filename: string
): Promise<{ success: boolean; message?: string; error?: string }> => {
  try {
    const response = await fetch(
      apiUrl(`/media/${encodeURIComponent(filename)}`),
      {
        method: "DELETE",
      }
    );

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || "Failed to delete file");
    }

    return await response.json();
  } catch (error) {
    console.error("Delete API error:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred",
    };
  }
};

// Clone/copy media file on server
export const cloneMediaFile = async (
  filename: string,
  originalName: string,
  suffix: string
): Promise<{
  success: boolean;
  filename?: string;
  originalName?: string;
  url?: string;
  fullUrl?: string;
  size?: number;
  error?: string;
}> => {
  try {
    const response = await fetch(apiUrl("/clone-media"), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        filename,
        originalName,
        suffix,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || "Failed to clone file");
    }

    return await response.json();
  } catch (error) {
    console.error("Clone API error:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred",
    };
  }
};

// Helper function to get media metadata
const getMediaMetadata = (
  file: File,
  mediaType: "video" | "image" | "audio"
): Promise<{
  durationInSeconds?: number;
  width: number;
  height: number;
}> => {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(file);

    if (mediaType === "video") {
      const video = document.createElement("video");
      video.preload = "metadata";

      video.onloadedmetadata = () => {
        const width = video.videoWidth;
        const height = video.videoHeight;
        const durationInSeconds = video.duration;

        URL.revokeObjectURL(url);
        resolve({
          durationInSeconds: isFinite(durationInSeconds)
            ? durationInSeconds
            : undefined,
          width,
          height,
        });
      };

      video.onerror = () => {
        URL.revokeObjectURL(url);
        reject(new Error("Failed to load video metadata"));
      };

      video.src = url;
    } else if (mediaType === "image") {
      const img = new Image();

      img.onload = () => {
        const width = img.naturalWidth;
        const height = img.naturalHeight;

        URL.revokeObjectURL(url);
        resolve({
          durationInSeconds: undefined, // Images don't have duration
          width,
          height,
        });
      };

      img.onerror = () => {
        URL.revokeObjectURL(url);
        reject(new Error("Failed to load image metadata"));
      };

      img.src = url;
    } else if (mediaType === "audio") {
      const audio = document.createElement("audio");
      audio.preload = "metadata";

      audio.onloadedmetadata = () => {
        const durationInSeconds = audio.duration;

        URL.revokeObjectURL(url);
        resolve({
          durationInSeconds: isFinite(durationInSeconds)
            ? durationInSeconds
            : undefined,
          width: 0, // Audio files don't have visual dimensions
          height: 0,
        });
      };

      audio.onerror = () => {
        URL.revokeObjectURL(url);
        reject(new Error("Failed to load audio metadata"));
      };

      audio.src = url;
    }
  });
};

export const useMediaBin = (
  handleDeleteScrubbersByMediaBinId: (mediaBinId: string) => void
) => {
  const [mediaBinItems, setMediaBinItems] = useState<MediaBinItem[]>([]);
  const [isMediaLoading, setIsMediaLoading] = useState<boolean>(true);
  const projectId = (() => {
    try {
      const m = window.location.pathname.match(/\/project\/([^/]+)/);
      return m ? m[1] : null;
    } catch {
      return null;
    }
  })();
  const [contextMenu, setContextMenu] = useState<{
    x: number;
    y: number;
    item: MediaBinItem;
  } | null>(null);

  // Hydrate existing assets for the logged-in user
  // DISABLED: Loading assets feature temporarily commented out
  /*
  useEffect(() => {
    const loadAssets = async () => {
      try {
        const url = projectId
          ? `/api/assets?projectId=${encodeURIComponent(projectId)}`
          : "/api/assets";
        const res = await fetch(apiUrl(url, false, true), {
          credentials: "include",
        });
        if (!res.ok) return;
        const json = await res.json();
        const assets = (json.assets || []) as Array<{
          id: string;
          name: string;
          mediaUrlRemote: string;
          width: number | null;
          height: number | null;
          durationInSeconds: number | null;
        }>;
        const items: MediaBinItem[] = assets.map((a) => ({
          id: a.id,
          name: a.name,
          mediaType: ((): "video" | "image" | "audio" | "text" => {
            const ext = a.name.toLowerCase();
            if (/(mp4|mov|webm|mkv|avi)$/.test(ext)) return "video";
            if (/(mp3|wav|aac|ogg|flac)$/.test(ext)) return "audio";
            if (/(jpg|jpeg|png|gif|bmp|webp)$/.test(ext)) return "image";
            return "image";
          })(),
          mediaUrlLocal: null, // restored assets will use remote URL; local may be null
          mediaUrlRemote: a.mediaUrlRemote,
          durationInSeconds: a.durationInSeconds ?? 0,
          media_width: a.width ?? 0,
          media_height: a.height ?? 0,
          text: null,
          isUploading: false,
          uploadProgress: null,
          left_transition_id: null,
          right_transition_id: null,
        }));
        // Merge: keep existing text items, replace non-text items with fetched assets
        setMediaBinItems((prev) => {
          const textItems = prev.filter((i) => i.mediaType === "text");
          return [...textItems, ...items];
        });
      } catch (e) {
        console.error("Failed to load assets", e);
      } finally {
        setIsMediaLoading(false);
      }
    };
    loadAssets();
  }, [projectId]);
  */

  // Manually set loading to false since we're not loading assets
  useEffect(() => {
    setIsMediaLoading(false);
  }, []);

  const handleAddMediaToBin = useCallback(async (file: File) => {
    const id = generateUUID();
    const name = file.name;
    let mediaType: "video" | "image" | "audio";
    if (file.type.startsWith("video/")) mediaType = "video";
    else if (file.type.startsWith("image/")) mediaType = "image";
    else if (file.type.startsWith("audio/")) mediaType = "audio";
    else {
      alert("Unsupported file type. Please select a video or image.");
      return;
    }

    console.log("Adding to bin:", name, mediaType);

    try {
      const mediaUrlLocal = URL.createObjectURL(file);

      console.log(`Parsing ${mediaType} file for metadata...`);
      const metadata = await getMediaMetadata(file, mediaType);
      console.log("Media metadata:", metadata);

      // Add item to media bin immediately with upload progress tracking
      const newItem: MediaBinItem = {
        id,
        name,
        mediaType,
        mediaUrlLocal,
        mediaUrlRemote: null, // Will be set after successful upload
        durationInSeconds: metadata.durationInSeconds ?? 0,
        media_width: metadata.width,
        media_height: metadata.height,
        text: null,
        isUploading: true,
        uploadProgress: 0,
        left_transition_id: null,
        right_transition_id: null,
        groupped_scrubbers: null,
      };
      setMediaBinItems(prev => [...prev, newItem]);

      const formData = new FormData();
      formData.append('media', file);

      console.log("Uploading file to server...");
      const uploadResponse = await axios.post(apiUrl('/upload'), formData, {
        onUploadProgress: (progressEvent) => {
          if (progressEvent.total) {
            const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
            console.log(`Upload progress: ${percentCompleted}%`);

            // Update upload progress in the media bin
            setMediaBinItems(prev =>
              prev.map(item =>
                item.id === id
                  ? { ...item, uploadProgress: percentCompleted }
                  : item
              )
            );
          }
        }
      });

      const uploadResult = uploadResponse.data;
      console.log("Upload successful:", uploadResult);

      // Update item with successful upload result and remove progress tracking
      setMediaBinItems(prev =>
        prev.map(item =>
          item.id === id
            ? {
              ...item,
              mediaUrlRemote: uploadResult.fullUrl,
              isUploading: false,
              uploadProgress: null
            }
            : item
        )
      );

    } catch (error) {
      console.error("Error adding media to bin:", error);
      const errorMessage = error instanceof Error ? error.message : "Unknown error";

      // Remove the failed item from media bin
      setMediaBinItems(prev => prev.filter(item => item.id !== id));

      throw new Error(`Failed to add media: ${errorMessage}`);
    }
  }, []);

  const handleAddTextToBin = useCallback((
    textContent: string,
    fontSize: number,
    fontFamily: string,
    color: string,
    textAlign: "left" | "center" | "right",
    fontWeight: "normal" | "bold"
  ) => {
    const newItem: MediaBinItem = {
      id: generateUUID(),
      name: textContent,
      mediaType: "text",
      media_width: 0,
      media_height: 0,
      text: {
        textContent,
        fontSize,
        fontFamily,
        color,
        textAlign,
        fontWeight,
        template: null,       // for now, maybe we can also allow text to have a template (same ones from captions)
      },
      mediaUrlLocal: null,
      mediaUrlRemote: null,
      durationInSeconds: 0,     // interesting code. i wish i remembered why i did this. maybe there's a better way.
      isUploading: false,
      uploadProgress: null,
      left_transition_id: null,
      right_transition_id: null,
      groupped_scrubbers: null,
    };
    setMediaBinItems(prev => [...prev, newItem]);
  }, []);

  const getMediaBinItems = useCallback(() => mediaBinItems, [mediaBinItems]);

  const setTextItems = useCallback((textItems: MediaBinItem[]) => {
    setMediaBinItems((prev) => {
      const withoutText = prev.filter((i) => i.mediaType !== "text");
      return [
        ...withoutText,
        ...textItems.map(
          (t): MediaBinItem => ({
            ...t,
            mediaType: "text" as const,
            mediaUrlLocal: null,
            mediaUrlRemote: null,
            isUploading: false,
            uploadProgress: null,
          })
        ),
      ];
    });
  }, []);

  const handleDeleteMedia = useCallback(async (item: MediaBinItem) => {
    try {
      if (item.mediaType === "text" || item.mediaType === "groupped_scrubber") {
        setMediaBinItems(prev => prev.filter(binItem => binItem.id !== item.id));

        // Also remove any scrubbers from the timeline that use this media
        if (handleDeleteScrubbersByMediaBinId) {
          handleDeleteScrubbersByMediaBinId(item.id);
        }

        if (!item.mediaUrlRemote) {
          console.error("No remote URL found for media item");
          return;
        }
      }
      // Call authenticated delete by asset id
      const assetId = item.id;
      const res = await fetch(apiUrl(`/api/assets/${assetId}`, false, true), {
        method: "DELETE",
        credentials: "include",
      });
      if (res.ok) {
        console.log(`Media deleted: ${item.name}`);
        // Remove from media bin state
        setMediaBinItems((prev) =>
          prev.filter((binItem) => binItem.id !== item.id)
        );
        // Also remove any scrubbers from the timeline that use this media
        if (handleDeleteScrubbersByMediaBinId) {
          handleDeleteScrubbersByMediaBinId(item.id);
        }
      } else {
        console.error("Failed to delete media:", await res.text());
      }
    } catch (error) {
      console.error("Error deleting media:", error);
    }
  }, [handleDeleteScrubbersByMediaBinId]);

  const handleSplitAudio = useCallback(async (videoItem: MediaBinItem) => {
    if (videoItem.mediaType !== "video") {
      throw new Error("Can only split audio from video files");
    }

    try {
      // Extract filename from mediaUrlRemote URL
      if (!videoItem.mediaUrlRemote) {
        throw new Error("No remote URL found for video item");
      }

      // Clone via authenticated API (server will copy within out/ and record)
      const res = await fetch(
        apiUrl(`/api/assets/${videoItem.id}/clone`, false, true),
        {
          method: "POST",
          credentials: "include",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ suffix: "(Audio)" }),
        }
      );
      if (!res.ok) throw new Error("Failed to clone media file");
      const cloneResult = await res.json();

      // Create a new audio media item using returned URL
      const audioItem: MediaBinItem = {
        id: generateUUID(),
        name: `${videoItem.name} (Audio)`,
        mediaType: "audio",
        mediaUrlLocal: videoItem.mediaUrlLocal, // Reuse the original video's blob URL
        mediaUrlRemote: cloneResult.asset?.mediaUrlRemote!,
        durationInSeconds: videoItem.durationInSeconds,
        media_width: 0, // Audio doesn't have visual dimensions
        media_height: 0,
        text: null,
        isUploading: false,
        uploadProgress: null,
        left_transition_id: null,
        right_transition_id: null,
        groupped_scrubbers: null,
      };

      // Add the audio item to the media bin
      setMediaBinItems((prev) => [...prev, audioItem]);
      setContextMenu(null); // Close context menu after action

      console.log(
        `Audio split successful: ${videoItem.name} -> ${audioItem.name}`
      );
    } catch (error) {
      console.error("Error splitting audio:", error);
      throw error;
    }
  }, []);

  // Handle right-click to show context menu
  const handleContextMenu = useCallback(
    (e: React.MouseEvent, item: MediaBinItem) => {
      e.preventDefault();
      setContextMenu({
        x: e.clientX,
        y: e.clientY,
        item,
      });
    },
    []
  );

  // Handle context menu actions
  const handleDeleteFromContext = useCallback(async () => {
    if (!contextMenu) return;
    await handleDeleteMedia(contextMenu.item);
    setContextMenu(null);
  }, [contextMenu, handleDeleteMedia]);

  const handleSplitAudioFromContext = useCallback(async () => {
    if (!contextMenu) return;
    await handleSplitAudio(contextMenu.item);
  }, [contextMenu, handleSplitAudio]);

  // Close context menu when clicking outside
  const handleCloseContextMenu = useCallback(() => {
    setContextMenu(null);
  }, []);

  const handleAddGroupToMediaBin = useCallback((groupedScrubber: ScrubberState, currentPixelsPerSecond: number) => {
    // Calculate the actual duration in seconds by dividing the current pixel width
    // by the current zoom-adjusted pixels per second - this gives us the true duration
    // regardless of zoom level
    const actualDurationInSeconds = groupedScrubber.width / currentPixelsPerSecond;

    // Create a new media bin item from the grouped scrubber
    const newItem: MediaBinItem = {
      id: groupedScrubber.id,
      name: groupedScrubber.name || "Grouped Media",
      mediaType: "groupped_scrubber",
      mediaUrlLocal: null,
      mediaUrlRemote: null,
      durationInSeconds: actualDurationInSeconds,
      media_width: groupedScrubber.media_width || 0,
      media_height: groupedScrubber.media_height || 0,
      text: null,
      isUploading: false,
      uploadProgress: null,
      left_transition_id: null,
      right_transition_id: null,
      groupped_scrubbers: groupedScrubber.groupped_scrubbers,
    };

    setMediaBinItems(prev => [...prev, newItem]);
    console.log("Added grouped scrubber to media bin:", newItem.name);
  }, []);

  return {
    mediaBinItems,
    isMediaLoading,
    getMediaBinItems,
    setTextItems,
    handleAddMediaToBin,
    handleAddTextToBin,
    handleDeleteMedia,
    handleSplitAudio,
    handleAddGroupToMediaBin,
    contextMenu,
    handleContextMenu,
    handleDeleteFromContext,
    handleSplitAudioFromContext,
    handleCloseContextMenu,
  };
};



================================================
FILE: app/hooks/useRenderer.ts
================================================
import { useState, useCallback } from "react";
import axios from "axios";
import {
  type TimelineDataItem,
  type TimelineState,
  FPS,
} from "~/components/timeline/types";
import { apiUrl } from "~/utils/api";

export const useRenderer = () => {
  const [isRendering, setIsRendering] = useState(false);
  const [renderStatus, setRenderStatus] = useState<string>("");

  const handleRenderVideo = useCallback(
    async (
      getTimelineData: () => TimelineDataItem[],
      timeline: TimelineState,
      compositionWidth: number | null,
      compositionHeight: number | null,
      getPixelsPerSecond: () => number
    ) => {
      setIsRendering(true);
      setRenderStatus("Starting render...");
      console.log("Render server base URL:", apiUrl("/render"));

      try {
        // Test server connection first
        setRenderStatus("Connecting to render server...");
        try {
          await axios.get(apiUrl("/health"), { timeout: 5000 });
        } catch (healthError) {
          throw new Error(
            "Cannot connect to render server. Make sure the server is running on http://localhost:8000"
          );
        }

        const timelineData = getTimelineData();
        // Calculate composition width if not provided
        if (compositionWidth === null) {
          let maxWidth = 0;
          for (const item of timelineData) {
            for (const scrubber of item.scrubbers) {
              if (
                scrubber.media_width !== null &&
                scrubber.media_width > maxWidth
              ) {
                maxWidth = scrubber.media_width;
              }
            }
          }
          compositionWidth = maxWidth || 1920; // Default to 1920 if no media found
        }

        // Calculate composition height if not provided
        if (compositionHeight === null) {
          let maxHeight = 0;
          for (const item of timelineData) {
            for (const scrubber of item.scrubbers) {
              if (
                scrubber.media_height !== null &&
                scrubber.media_height > maxHeight
              ) {
                maxHeight = scrubber.media_height;
              }
            }
          }
          compositionHeight = maxHeight || 1080; // Default to 1080 if no media found
        }

        console.log("Composition width:", compositionWidth);
        console.log("Composition height:", compositionHeight);

        if (
          timeline.tracks.length === 0 ||
          timeline.tracks.every((t) => t.scrubbers.length === 0)
        ) {
          setRenderStatus("Error: No timeline data to render");
          setIsRendering(false);
          return;
        }

        setRenderStatus("Rendering video...");

        const response = await axios.post(
          apiUrl("/render"),
          {
            timelineData: timelineData,
            compositionWidth: compositionWidth,
            compositionHeight: compositionHeight,
            durationInFrames: (() => {
              const timelineData = getTimelineData();
              let maxEndTime = 0;

              timelineData.forEach((timelineItem) => {
                timelineItem.scrubbers.forEach((scrubber) => {
                  if (scrubber.endTime > maxEndTime) {
                    maxEndTime = scrubber.endTime;
                  }
                });
              });
              console.log("Max end time:", maxEndTime * 30);
              return Math.ceil(maxEndTime * FPS);
            })(),
            getPixelsPerSecond: getPixelsPerSecond(),
          },
          {
            responseType: "blob",
            timeout: 900000,
            onDownloadProgress: (progressEvent) => {
              if (progressEvent.lengthComputable && progressEvent.total) {
                const percentCompleted = Math.round(
                  (progressEvent.loaded * 100) / progressEvent.total
                );
                setRenderStatus(
                  `Downloading rendered video: ${percentCompleted}%`
                );
              }
            },
          }
        );

        const url = window.URL.createObjectURL(new Blob([response.data]));
        const link = document.createElement("a");
        link.href = url;
        link.setAttribute("download", "rendered-video.mp4");
        document.body.appendChild(link);
        link.click();
        link.remove();
        window.URL.revokeObjectURL(url);

        setRenderStatus("Video rendered and downloaded successfully!");
      } catch (error) {
        console.error("Render error:", error);
        if (axios.isAxiosError(error)) {
          if (error.code === "ECONNABORTED") {
            setRenderStatus("Error: Render timeout - try a shorter video");
          } else if (error.response?.status === 500) {
            setRenderStatus(
              `Error: ${
                error.response.data?.message || "Server error during rendering"
              }`
            );
          } else if (error.request) {
            setRenderStatus(
              "Error: Cannot connect to render server. Make sure the backend is running on localhost:8000. Run: pnpm dlx tsx app/videorender/videorender.ts"
            );
          } else {
            setRenderStatus(`Error: ${error.message}`);
          }
        } else {
          setRenderStatus("Error: Unknown rendering error occurred");
        }
      } finally {
        setIsRendering(false);
        setTimeout(() => setRenderStatus(""), 8000); // Show error longer
      }
    },
    []
  );

  return {
    isRendering,
    renderStatus,
    handleRenderVideo,
  };
};



================================================
FILE: app/hooks/useRuler.ts
================================================
import { useState, useCallback, useEffect, useRef } from "react";
import type { PlayerRef } from "@remotion/player";
import { PIXELS_PER_SECOND, FPS } from "~/components/timeline/types";

export const useRuler = (
  playerRef: React.RefObject<PlayerRef | null>,
  timelineWidth: number,
  pixelsPerSecond: number
) => {
  const [rulerPositionPx, setRulerPositionPx] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);
  const [isDraggingRuler, setIsDraggingRuler] = useState(false);

  const isSeekingRef = useRef(false);
  const isUpdatingFromPlayerRef = useRef(false);

  const handleRulerDrag = useCallback(
    (newPositionPx: number) => {
      const clampedPositionPx = Math.max(
        0,
        Math.min(newPositionPx, timelineWidth)
      );
      setRulerPositionPx(clampedPositionPx);

      // Sync with player when not already updating from player
      if (playerRef.current && !isUpdatingFromPlayerRef.current) {
        isSeekingRef.current = true;
        const timeInSeconds = clampedPositionPx / pixelsPerSecond;
        const frame = Math.round(timeInSeconds * FPS);
        playerRef.current.seekTo(frame);
        // Reset seeking flag on next animation frame
        requestAnimationFrame(() => {
          isSeekingRef.current = false;
        });
      }
    },
    [timelineWidth, playerRef, pixelsPerSecond]
  );

  const handleRulerMouseDown = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    setIsDraggingRuler(true);
  }, []);

  const handleRulerMouseMove = useCallback(
    (e: MouseEvent, containerRef: React.RefObject<HTMLDivElement | null>) => {
      if (!isDraggingRuler || !containerRef.current) return;

      e.preventDefault();

      // Get the timeline container (the one that scrolls)
      const timelineContainer = containerRef.current;
      const rect = timelineContainer.getBoundingClientRect();

      // Calculate mouse position relative to the timeline, accounting for scroll
      const scrollLeft = timelineContainer.scrollLeft || 0;
      const mouseX = e.clientX - rect.left + scrollLeft;

      handleRulerDrag(mouseX);
    },
    [isDraggingRuler, handleRulerDrag]
  );

  const handleRulerMouseUp = useCallback(() => {
    setIsDraggingRuler(false);
  }, []);

  const updateRulerFromPlayer = useCallback(
    (frame: number) => {
      if (!isSeekingRef.current) {
        isUpdatingFromPlayerRef.current = true;
        const timeInSeconds = frame / FPS;
        const newPositionPx = timeInSeconds * pixelsPerSecond;
        setRulerPositionPx(Math.max(0, Math.min(newPositionPx, timelineWidth)));
        // Reset flag after state update
        requestAnimationFrame(() => {
          isUpdatingFromPlayerRef.current = false;
        });
      }
    },
    [pixelsPerSecond, timelineWidth]
  );

  const handleScroll = useCallback(
    (
      containerRef: React.RefObject<HTMLDivElement | null>,
      expandTimeline: () => boolean
    ) => {
      if (containerRef.current) {
        setScrollLeft(containerRef.current.scrollLeft);
      }
      expandTimeline();
    },
    []
  );

  // No smoothing: frame updates drive the ruler; explicit seeks happen on drag or click

  // Listen for player frame updates
  useEffect(() => {
    const player = playerRef.current;
    if (player) {
      const handleFrameUpdate = (e: { detail: { frame: number } }) => {
        // Don't update ruler position if we're seeking or dragging
        if (isSeekingRef.current || isDraggingRuler) return;

        const currentFrame = e.detail.frame;
        const currentTimeInSeconds = currentFrame / FPS;
        const newPositionPx = currentTimeInSeconds * pixelsPerSecond;
        isUpdatingFromPlayerRef.current = true;
        setRulerPositionPx(newPositionPx);
        requestAnimationFrame(() => {
          isUpdatingFromPlayerRef.current = false;
        });
      };

      const handleSeeked = () => {
        // Small delay to ensure seek is complete
        setTimeout(() => {
          isSeekingRef.current = false;
        }, 50);
      };

      player.addEventListener("frameupdate", handleFrameUpdate);
      player.addEventListener("seeked", handleSeeked);

      return () => {
        player.removeEventListener("frameupdate", handleFrameUpdate);
        player.removeEventListener("seeked", handleSeeked);
      };
    }
  }, [isDraggingRuler, rulerPositionPx, playerRef, pixelsPerSecond]);

  return {
    rulerPositionPx,
    scrollLeft,
    isDraggingRuler,
    handleRulerDrag,
    handleRulerMouseDown,
    handleRulerMouseMove,
    handleRulerMouseUp,
    handleScroll,
    updateRulerFromPlayer,
  };
};



================================================
FILE: app/lib/assets.repo.ts
================================================
import { Pool } from "pg";
import crypto from "crypto";

export type AssetRecord = {
  id: string;
  user_id: string;
  project_id: string | null;
  original_name: string;
  storage_key: string;
  mime_type: string;
  size_bytes: number;
  width: number | null;
  height: number | null;
  duration_seconds: number | null;
  created_at: string;
  deleted_at: string | null;
};

let pool: Pool | null = null;

function getPool(): Pool {
  if (!pool) {
    const rawDbUrl = process.env.DATABASE_URL || "";
    let connectionString = rawDbUrl;
    try {
      const u = new URL(rawDbUrl);
      u.search = "";
      connectionString = u.toString();
    } catch {
      // keep as-is
    }
    pool = new Pool({
      connectionString,
      ssl: connectionString.includes('supabase.co') 
        ? { rejectUnauthorized: false } // Supabase uses certificates that may not be trusted by Node.js
        : process.env.NODE_ENV === "production" 
          ? { rejectUnauthorized: true }
          : { rejectUnauthorized: false },
    });
  }
  return pool;
}

// Schema creation is handled by SQL migrations in /migrations.

export async function insertAsset(params: {
  userId: string;
  projectId?: string | null;
  originalName: string;
  storageKey: string;
  mimeType: string;
  sizeBytes: number;
  width?: number | null;
  height?: number | null;
  durationSeconds?: number | null;
}): Promise<AssetRecord> {
  const client = await getPool().connect();
  try {
    const id = crypto.randomUUID();
    const { rows } = await client.query<AssetRecord>(
      `insert into assets (id, user_id, project_id, original_name, storage_key, mime_type, size_bytes, width, height, duration_seconds)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       returning *`,
      [
        id,
        params.userId,
        params.projectId ?? null,
        params.originalName,
        params.storageKey,
        params.mimeType,
        params.sizeBytes,
        params.width ?? null,
        params.height ?? null,
        params.durationSeconds ?? null,
      ]
    );
    return rows[0];
  } finally {
    client.release();
  }
}

export async function listAssetsByUser(
  userId: string,
  projectId: string | null
): Promise<AssetRecord[]> {
  const client = await getPool().connect();
  try {
    const query =
      projectId === null
        ? `select * from assets where user_id = $1 and project_id is null and deleted_at is null order by created_at desc`
        : `select * from assets where user_id = $1 and project_id = $2 and deleted_at is null order by created_at desc`;
    const params = projectId === null ? [userId] : [userId, projectId];
    const { rows } = await client.query<AssetRecord>(query, params);
    return rows;
  } finally {
    client.release();
  }
}

export async function getAssetById(id: string): Promise<AssetRecord | null> {
  const client = await getPool().connect();
  try {
    const { rows } = await client.query<AssetRecord>(
      `select * from assets where id = $1 and deleted_at is null`,
      [id]
    );
    return rows[0] ?? null;
  } finally {
    client.release();
  }
}

export async function softDeleteAsset(
  id: string,
  userId: string
): Promise<void> {
  const client = await getPool().connect();
  try {
    await client.query(
      `update assets set deleted_at = now() where id = $1 and user_id = $2 and deleted_at is null`,
      [id, userId]
    );
  } finally {
    client.release();
  }
}



================================================
FILE: app/lib/auth.client.ts
================================================
import { createAuthClient } from "better-auth/react";

const baseURL = ((): string => {
  if (typeof window !== "undefined" && window.location?.origin) {
    return `${window.location.origin}`; // base path will be provided by server config
  }
  return "http://localhost:5173";
})();

export const authClient = createAuthClient({ baseURL, basePath: "/api/auth" });



================================================
FILE: app/lib/auth.server.ts
================================================
import "dotenv/config";
import { betterAuth } from "better-auth";
import { Pool } from "pg";


const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || "";
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET || "";

// Strip query params like sslmode so Pool options below take full effect
const rawDbUrl = process.env.DATABASE_URL || "";
let connectionString = rawDbUrl;
try {
  const u = new URL(rawDbUrl);
  u.search = "";
  connectionString = u.toString();
} catch {
  // keep as-is
}

// Rely on Better Auth's official CLI migration for schema.

console.log("🔧 Initializing Better Auth with:");
console.log("🔧 DATABASE_URL:", process.env.DATABASE_URL ? "SET" : "NOT SET");
console.log("🔧 GOOGLE_CLIENT_ID:", GOOGLE_CLIENT_ID ? "SET" : "NOT SET");
console.log(
  "🔧 GOOGLE_CLIENT_SECRET:",
  GOOGLE_CLIENT_SECRET ? "SET" : "NOT SET"
);
console.log("🔧 Note: baseURL will be auto-detected from request headers");

// Build trusted origins from env + sensible defaults
const defaultTrustedOrigins = [
  // Dev
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  // Prod (can be overridden/extended via env)
  "https://trykimu.com",
  "https://www.trykimu.com",
];

const envTrustedOrigins = (process.env.AUTH_TRUSTED_ORIGINS || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

const trustedOrigins = Array.from(
  new Set([...defaultTrustedOrigins, ...envTrustedOrigins])
);

export const auth = betterAuth({
  basePath: "/api/auth",
  // Force baseURL in development so Google gets the correct redirect_uri
  baseURL:
    process.env.AUTH_BASE_URL ||
    (process.env.NODE_ENV === "development"
      ? "http://localhost:5173"
      : undefined),
  // Trust proxy headers to detect HTTPS for secure cookies
  trustProxy: process.env.NODE_ENV === "production",
  // Let Better Auth auto-detect baseURL from the request
  database: new Pool({
    connectionString,
    ssl: connectionString.includes('supabase.co') 
      ? { rejectUnauthorized: false } // Supabase uses certificates that may not be trusted by Node.js
      : process.env.NODE_ENV === "production" 
        ? { rejectUnauthorized: true }
        : { rejectUnauthorized: false },
  }),

  // Add debugging and callback configuration
  logger: {
    level: "debug",
  },

  socialProviders: {
    google: {
      clientId: GOOGLE_CLIENT_ID,
      clientSecret: GOOGLE_CLIENT_SECRET,
      // Let Better Auth use its default callback endpoint
      // redirectURI will be automatically set to: {baseURL}/api/auth/callback/google
    },
  },
  session: {
    // Increase session expiry
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    cookie: {
      // Use "lax" for same-site requests, "none" only needed for cross-origin
      sameSite: process.env.NODE_ENV === "production" ? "lax" : "none",
      secure: process.env.NODE_ENV === "production",
      // In production, pin cookie domain to apex so subdomains (if any) share
      // Set via env if provided, else let browser infer from host header
      ...(process.env.AUTH_COOKIE_DOMAIN
        ? { domain: process.env.AUTH_COOKIE_DOMAIN }
        : {}),
      path: "/",
    },
  },
  // Trusted origins for CORS and cookies
  trustedOrigins,
});
// Schema is managed via CLI migrations.



================================================
FILE: app/lib/migrate.ts
================================================
import "dotenv/config";
import { Pool } from "pg";
import fs from "fs";
import path from "path";

async function run() {
  const rawDbUrl = process.env.DATABASE_URL || "";
  let connectionString = rawDbUrl;
  try {
    const u = new URL(rawDbUrl);
    u.search = "";
    connectionString = u.toString();
  } catch {
    console.error("Invalid database URL");
    process.exitCode = 1;
    return;
  }

  const pool = new Pool({
    connectionString,
    ssl: connectionString.includes('supabase.co') 
      ? { rejectUnauthorized: false } // Supabase uses certificates that may not be trusted by Node.js
      : process.env.NODE_ENV === "production" 
        ? { rejectUnauthorized: true }
        : { rejectUnauthorized: false },
  });
  const client = await pool.connect();
  try {
    await client.query("begin");
    const dir = path.resolve("migrations");
    const files = fs
      .readdirSync(dir)
      .filter((f) => f.endsWith(".sql"))
      .sort();
    for (const file of files) {
      const sql = fs.readFileSync(path.join(dir, file), "utf8");
      console.log(`Running migration: ${file}`);
      await client.query(sql);
    }
    await client.query("commit");
    console.log("All migrations applied successfully.");
  } catch (err) {
    await client.query("rollback");
    console.error("Migration failed:", err);
    process.exitCode = 1;
  } finally {
    client.release();
    await pool.end();
  }
}

run();



================================================
FILE: app/lib/projects.repo.ts
================================================
import { Pool } from "pg";
import crypto from "crypto";

let pool: Pool | null = null;

function getPool(): Pool {
  if (!pool) {
    const rawDbUrl = process.env.DATABASE_URL || "";
    let connectionString = rawDbUrl;
    try {
      const u = new URL(rawDbUrl);
      u.search = "";
      connectionString = u.toString();
    } catch {
      throw new Error("Invalid database URL");
    }
    pool = new Pool({ 
      connectionString, 
      ssl: connectionString.includes('supabase.co') 
        ? { rejectUnauthorized: false } // Supabase uses certificates that may not be trusted by Node.js
        : process.env.NODE_ENV === "production" 
          ? { rejectUnauthorized: true }
          : { rejectUnauthorized: false }
    });
  }
  return pool;
}

export type ProjectRecord = {
  id: string;
  user_id: string;
  name: string;
  created_at: string;
  updated_at: string;
};

export async function createProject(params: {
  userId: string;
  name: string;
}): Promise<ProjectRecord> {
  const client = await getPool().connect();
  try {
    const id = crypto.randomUUID();
    const { rows } = await client.query<ProjectRecord>(
      `insert into projects (id, user_id, name) values ($1,$2,$3) returning *`,
      [id, params.userId, params.name]
    );
    return rows[0];
  } finally {
    client.release();
  }
}

export async function listProjectsByUser(
  userId: string
): Promise<ProjectRecord[]> {
  const client = await getPool().connect();
  try {
    const { rows } = await client.query<ProjectRecord>(
      `select * from projects where user_id = $1 order by created_at desc`,
      [userId]
    );
    return rows;
  } finally {
    client.release();
  }
}

export async function getProjectById(
  id: string
): Promise<ProjectRecord | null> {
  const client = await getPool().connect();
  try {
    const { rows } = await client.query<ProjectRecord>(
      `select * from projects where id = $1`,
      [id]
    );
    return rows[0] ?? null;
  } finally {
    client.release();
  }
}

export async function deleteProjectById(
  id: string,
  userId: string
): Promise<boolean> {
  const client = await getPool().connect();
  try {
    const { rowCount } = await client.query(
      `delete from projects where id = $1 and user_id = $2`,
      [id, userId]
    );
    return (rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}



================================================
FILE: app/lib/timeline.store.ts
================================================
import fs from "fs";
import path from "path";
import type { MediaBinItem, TimelineState } from "~/components/timeline/types";

const TIMELINE_DIR = process.env.TIMELINE_DIR || path.resolve("project_data");

function ensureDir(): void {
  if (!fs.existsSync(TIMELINE_DIR))
    fs.mkdirSync(TIMELINE_DIR, { recursive: true });
}

function getFilePath(projectId: string): string {
  ensureDir();
  // Validate and sanitize projectId to prevent path traversal
  if (!projectId || typeof projectId !== 'string') {
    throw new Error('Invalid project ID');
  }
  // Remove any path traversal attempts and invalid characters
  const sanitizedId = projectId.replace(/[^a-zA-Z0-9_-]/g, '');
  if (sanitizedId !== projectId || sanitizedId.length === 0) {
    throw new Error('Invalid project ID format');
  }
  const filePath = path.resolve(TIMELINE_DIR, `${sanitizedId}.json`);
  // Ensure the resolved path is still within TIMELINE_DIR
  if (!filePath.startsWith(path.resolve(TIMELINE_DIR))) {
    throw new Error('Invalid path');
  }
  return filePath;
}

export type ProjectStateFile = {
  timeline: TimelineState;
  textBinItems: MediaBinItem[];
};

function defaultTimeline(): TimelineState {
  return {
    tracks: [
      { id: "track-1", scrubbers: [], transitions: [] },
      { id: "track-2", scrubbers: [], transitions: [] },
      { id: "track-3", scrubbers: [], transitions: [] },
      { id: "track-4", scrubbers: [], transitions: [] },
    ],
  };
}

export async function loadProjectState(
  projectId: string
): Promise<ProjectStateFile> {
  const file = getFilePath(projectId);
  try {
    const raw = await fs.promises.readFile(file, "utf8");
    const parsed = JSON.parse(raw);
    if (
      parsed &&
      typeof parsed === "object" &&
      ("timeline" in parsed || "textBinItems" in parsed)
    ) {
      return {
        timeline: parsed.timeline ?? defaultTimeline(),
        textBinItems: Array.isArray(parsed.textBinItems)
          ? parsed.textBinItems
          : [],
      };
    }
    // legacy file stored just the timeline
    return { timeline: parsed, textBinItems: [] };
  } catch {
    return { timeline: defaultTimeline(), textBinItems: [] };
  }
}

export async function saveProjectState(
  projectId: string,
  state: ProjectStateFile
): Promise<void> {
  const file = getFilePath(projectId);
  await fs.promises.writeFile(file, JSON.stringify(state), "utf8");
}

// Backwards-compatible helpers
export async function loadTimeline(projectId: string): Promise<TimelineState> {
  const state = await loadProjectState(projectId);
  return state.timeline;
}

export async function saveTimeline(
  projectId: string,
  timeline: TimelineState
): Promise<void> {
  const prev = await loadProjectState(projectId);
  await saveProjectState(projectId, {
    timeline,
    textBinItems: prev.textBinItems,
  });
}



================================================
FILE: app/lib/utils.ts
================================================
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}



================================================
FILE: app/routes/api.assets.$.tsx
================================================
import { auth } from "~/lib/auth.server";
import {
  insertAsset,
  listAssetsByUser,
  getAssetById,
  softDeleteAsset,
} from "~/lib/assets.repo";
import fs from "fs";
import path from "path";

const OUT_DIR = path.resolve("out");

async function requireUserId(request: Request): Promise<string> {
  // Try Better Auth runtime API first
  try {
    // @ts-ignore - runtime API may not be typed
    const session = await auth.api?.getSession?.({ headers: request.headers });
    const userId: string | undefined =
      session?.user?.id ?? session?.session?.userId;
    if (userId) return String(userId);
  } catch {
    console.error("Failed to get session");
  }

  // Fallback: call /api/auth/session with forwarded cookies
  const host =
    request.headers.get("x-forwarded-host") ||
    request.headers.get("host") ||
    "localhost:5173";
  const proto =
    request.headers.get("x-forwarded-proto") ||
    (host.includes("localhost") ? "http" : "https");
  const base = `${proto}://${host}`;
  const cookie = request.headers.get("cookie") || "";
  const res = await fetch(`${base}/api/auth/session`, {
    headers: {
      Cookie: cookie,
      Accept: "application/json",
    },
    method: "GET",
  });
  if (!res.ok) {
    throw new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  const json = await res.json().catch(() => ({}));
  const uid: string | undefined =
    json?.user?.id ||
    json?.user?.userId ||
    json?.session?.user?.id ||
    json?.session?.userId ||
    json?.data?.user?.id ||
    json?.data?.user?.userId;
  if (!uid) {
    throw new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  return String(uid);
}

function inferMediaTypeFromName(
  name: string,
  fallback: string = "application/octet-stream"
): string {
  const ext = path.extname(name).toLowerCase();
  if ([".mp4", ".mov", ".webm", ".mkv", ".avi"].includes(ext)) return "video/*";
  if ([".mp3", ".wav", ".aac", ".ogg", ".flac"].includes(ext)) return "audio/*";
  if ([".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"].includes(ext))
    return "image/*";
  return fallback;
}

export async function loader({ request }: { request: Request }) {
  const url = new URL(request.url);
  const pathname = url.pathname;

  const userId = await requireUserId(request);

  // GET /api/assets[?projectId=...] -> list assets for user
  if (pathname.endsWith("/api/assets") && request.method === "GET") {
    const projectIdParam = new URL(request.url).searchParams.get("projectId");
    const projectId = projectIdParam ? String(projectIdParam) : null;
    const rows = await listAssetsByUser(userId, projectId);
    const items = rows.map((r) => ({
      id: r.id,
      name: r.original_name,
      mime_type: r.mime_type,
      size_bytes: r.size_bytes,
      width: r.width,
      height: r.height,
      duration_seconds: r.duration_seconds,
      durationInSeconds: r.duration_seconds, // camelCase for frontend
      created_at: r.created_at,
      mediaUrlRemote: `/api/assets/${r.id}/raw`,
      fullUrl: `http://localhost:8000/media/${encodeURIComponent(
        r.storage_key
      )}`,
    }));
    return new Response(JSON.stringify({ assets: items }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // GET /api/assets/:id/raw -> stream file with auth
  const rawMatch = pathname.match(/\/api\/assets\/([^/]+)\/raw$/);
  if (rawMatch && request.method === "GET") {
    const assetId = rawMatch[1];
    const asset = await getAssetById(assetId);
    if (!asset || asset.user_id !== userId) {
      return new Response(JSON.stringify({ error: "Not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }
    // Sanitize storage_key to prevent path traversal
    const sanitizedKey = path.basename(asset.storage_key);
    const filePath = path.resolve(OUT_DIR, sanitizedKey);
    if (!filePath.startsWith(OUT_DIR) || !fs.existsSync(filePath)) {
      return new Response(JSON.stringify({ error: "Not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Support range requests for video/audio
    const stat = fs.statSync(filePath);
    const range = request.headers.get("range");
    const contentType =
      asset.mime_type || inferMediaTypeFromName(asset.original_name);
    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : stat.size - 1;
      if (
        isNaN(start) ||
        isNaN(end) ||
        start > end ||
        start < 0 ||
        end >= stat.size
      ) {
        return new Response(undefined, { status: 416 });
      }
      const chunkSize = end - start + 1;
      const stream = fs.createReadStream(filePath, { start, end });
      return new Response(stream as unknown as BodyInit, {
        status: 206,
        headers: {
          "Content-Range": `bytes ${start}-${end}/${stat.size}`,
          "Accept-Ranges": "bytes",
          "Content-Length": String(chunkSize),
          "Content-Type": contentType,
        },
      });
    }

    const stream = fs.createReadStream(filePath);
    return new Response(stream as unknown as BodyInit, {
      status: 200,
      headers: {
        "Content-Length": String(stat.size),
        "Content-Type": contentType,
      },
    });
  }

  return new Response("Not Found", { status: 404 });
}

export async function action({ request }: { request: Request }) {
  const url = new URL(request.url);
  const pathname = url.pathname;
  const method = request.method.toUpperCase();

  const userId = await requireUserId(request);

  // POST /api/assets/upload -> proxy file to existing 8000 upload and record DB
  if (pathname.endsWith("/api/assets/upload") && method === "POST") {
    const width = Number(request.headers.get("x-media-width") || "") || null;
    const height = Number(request.headers.get("x-media-height") || "") || null;
    const duration =
      Number(request.headers.get("x-media-duration") || "") || null;
    const originalNameHeader = request.headers.get("x-original-name") || "file";
    const projectIdHeader = request.headers.get("x-project-id");

    // Parse incoming multipart form
    const incoming = await request.formData();
    const media = incoming.get("media");
    if (!(media instanceof Blob)) {
      return new Response(JSON.stringify({ error: "No file provided" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Reconstruct a new FormData and forward to 8000 so boundary is correct; faster and streams
    const form = new FormData();
    const filenameFor8000 = (media as {name?: string})?.name || originalNameHeader || "upload.bin";
    form.append("media", media, filenameFor8000);

    // Use HTTPS in production, HTTP only for local development
    const uploadUrl = process.env.NODE_ENV === "production" 
      ? process.env.UPLOAD_SERVICE_URL || "https://localhost:8000/upload"
      : "http://localhost:8000/upload";
    
    const forwardRes = await fetch(uploadUrl, {
      method: "POST",
      body: form,
    });

    if (!forwardRes.ok) {
      const errText = await forwardRes.text().catch(() => "");
      return new Response(
        JSON.stringify({ error: "Upload failed", detail: errText }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }
  
    const json = await forwardRes.json();
    const filename: string = json.filename;
    const size: number = json.size;
    const mime = inferMediaTypeFromName(
      filenameFor8000,
      "application/octet-stream"
    );

    const record = await insertAsset({
      userId,
      projectId: projectIdHeader || null,
      originalName: filenameFor8000,
      storageKey: filename,
      mimeType: mime,
      sizeBytes: Number(size) || 0,
      width,
      height,
      durationSeconds: duration,
    });

    return new Response(
      JSON.stringify({
        success: true,
        asset: {
          id: record.id,
          name: record.original_name,
          mediaUrlRemote: `/api/assets/${record.id}/raw`,
          fullUrl: `http://localhost:8000/media/${encodeURIComponent(
            filename
          )}`,
          width: record.width,
          height: record.height,
          durationInSeconds: record.duration_seconds,
          size: record.size_bytes,
        },
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  // POST /api/assets/register -> register an already-uploaded file from out/
  if (pathname.endsWith("/api/assets/register") && method === "POST") {
    const body = await request.json().catch(() => ({}));
    const filename: string | undefined = body.filename;
    const originalName: string | undefined = body.originalName;
    const size: number | undefined = body.size;
    const width: number | null =
      typeof body.width === "number" ? body.width : null;
    const height: number | null =
      typeof body.height === "number" ? body.height : null;
    const duration: number | null =
      typeof body.duration === "number" ? body.duration : null;

    if (!filename || !originalName) {
      return new Response(
        JSON.stringify({ error: "filename and originalName are required" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }
    const filePath = path.resolve(OUT_DIR, decodeURIComponent(filename));
    if (!filePath.startsWith(OUT_DIR) || !fs.existsSync(filePath)) {
      return new Response(JSON.stringify({ error: "File not found in out/" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }
    const stat = fs.statSync(filePath);
    const mime = inferMediaTypeFromName(
      originalName,
      "application/octet-stream"
    );

    const record = await insertAsset({
      userId,
      originalName,
      storageKey: path.basename(filePath),
      mimeType: mime,
      sizeBytes: typeof size === "number" ? size : stat.size,
      width,
      height,
      durationSeconds: duration,
    });

    return new Response(
      JSON.stringify({
        success: true,
        asset: {
          id: record.id,
          name: record.original_name,
          mediaUrlRemote: `/api/assets/${record.id}/raw`,
          fullUrl: `http://localhost:8000/media/${encodeURIComponent(
            record.storage_key
          )}`,
          width: record.width,
          height: record.height,
          durationInSeconds: record.duration_seconds,
          size: record.size_bytes,
        },
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  // DELETE /api/assets/:id -> delete
  const delMatch = pathname.match(/\/api\/assets\/([^/]+)$/);
  if (delMatch && method === "DELETE") {
    const assetId = delMatch[1];
    const asset = await getAssetById(assetId);
    if (!asset || asset.user_id !== userId) {
      return new Response(JSON.stringify({ error: "Not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }
    // Sanitize storage_key to prevent path traversal
    const sanitizedKey = path.basename(asset.storage_key);
    const filePath = path.resolve(OUT_DIR, sanitizedKey);
    if (filePath.startsWith(OUT_DIR) && fs.existsSync(filePath)) {
      try {
        fs.unlinkSync(filePath);
      } catch {
        /* ignore */
      }
    }
    await softDeleteAsset(assetId, userId);
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // POST /api/assets/:id/clone -> clone to new file and record
  const cloneMatch = pathname.match(/\/api\/assets\/([^/]+)\/clone$/);
  if (cloneMatch && method === "POST") {
    const assetId = cloneMatch[1];
    const suffix = (await request.json().catch(() => ({})))?.suffix || "copy";
    const asset = await getAssetById(assetId);
    if (!asset || asset.user_id !== userId) {
      return new Response(JSON.stringify({ error: "Not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }
    // Sanitize storage_key to prevent path traversal
    const sanitizedKey = path.basename(asset.storage_key);
    const srcPath = path.resolve(OUT_DIR, sanitizedKey);
    if (!srcPath.startsWith(OUT_DIR) || !fs.existsSync(srcPath)) {
      return new Response(JSON.stringify({ error: "Source missing" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }
    const timestamp = Date.now();
    const ext = path.extname(sanitizedKey);
    const base = path.basename(sanitizedKey, ext);
    // Sanitize suffix to prevent path traversal in filename
    const sanitizedSuffix = suffix.replace(/[^a-zA-Z0-9_-]/g, '');
    const newFilename = `${base}_${sanitizedSuffix}_${timestamp}${ext}`;
    const destPath = path.resolve(OUT_DIR, newFilename);
    fs.copyFileSync(srcPath, destPath);

    const stat = fs.statSync(destPath);
    const record = await insertAsset({
      userId,
      projectId: asset.project_id ?? null,
      originalName: `${asset.original_name} ${suffix}`.trim(),
      storageKey: newFilename,
      mimeType: asset.mime_type,
      sizeBytes: stat.size,
      width: asset.width,
      height: asset.height,
      durationSeconds: asset.duration_seconds,
    });

    return new Response(
      JSON.stringify({
        success: true,
        asset: {
          id: record.id,
          name: record.original_name,
          mediaUrlRemote: `/api/assets/${record.id}/raw`,
          fullUrl: `http://localhost:8000/media/${encodeURIComponent(
            newFilename
          )}`,
          width: record.width,
          height: record.height,
          durationInSeconds: record.duration_seconds,
          size: record.size_bytes,
        },
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  return new Response("Not Found", { status: 404 });
}



================================================
FILE: app/routes/api.auth.$.tsx
================================================
import type { Route } from "./+types/api.auth.$";
import { auth } from "~/lib/auth.server";

export async function loader({ request }: Route.LoaderArgs) {
  // Forward the request to Better Auth; it handles all subpaths
  const url = new URL(request.url);
  const isCallback = url.pathname.includes("/api/auth/callback/");
  const res = await auth.handler(request);
  // Normalize no-session to 200 so clients can treat it as "logged out"
  try {
    if (url.pathname.endsWith("/session") && res.status === 404) {
      return new Response(JSON.stringify({ user: null }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }
  } catch {
    console.error("Failed to get session");
  }
  // After successful OAuth callback, redirect to /projects
  if (isCallback && (res.status === 200 || res.status === 302)) {
    const headers = new Headers(res.headers);
    headers.set("Location", "/projects");
    return new Response(null, { status: 302, headers });
  }
  return res;
}

export async function action({ request }: Route.ActionArgs) {
  return auth.handler(request);
}



================================================
FILE: app/routes/api.projects.$.tsx
================================================
import { auth } from "~/lib/auth.server";
import {
  createProject,
  getProjectById,
  listProjectsByUser,
  deleteProjectById,
} from "~/lib/projects.repo";
import {
  listAssetsByUser,
  getAssetById,
  softDeleteAsset,
} from "~/lib/assets.repo";
import fs from "fs";
import path from "path";
import {
  loadTimeline,
  saveTimeline,
  loadProjectState,
  saveProjectState,
} from "~/lib/timeline.store";
import type { MediaBinItem, TimelineState } from "~/components/timeline/types";

async function requireUserId(request: Request): Promise<string> {
  try {
    const session = await auth.api?.getSession?.({ headers: request.headers });
    const uid: string | undefined =
      session?.user?.id || session?.session?.userId;
    if (uid) return String(uid);
  } catch {
    console.error("Failed to get session");
  }
  const host =
    request.headers.get("x-forwarded-host") ||
    request.headers.get("host") ||
    "localhost:5173";
  const proto =
    request.headers.get("x-forwarded-proto") ||
    (host.includes("localhost") ? "http" : "https");
  const base = `${proto}://${host}`;
  const res = await fetch(`${base}/api/auth/session`, {
    headers: { Cookie: request.headers.get("cookie") || "" },
  });
  if (!res.ok) throw new Response("Unauthorized", { status: 401 });
  const json = await res.json().catch(() => ({}));
  const uid2: string | undefined =
    json?.user?.id ||
    json?.userId ||
    json?.session?.userId ||
    json?.data?.user?.id;
  if (!uid2) throw new Response("Unauthorized", { status: 401 });
  return String(uid2);
}

export async function loader({ request }: { request: Request }) {
  const url = new URL(request.url);
  const pathname = url.pathname;
  const userId = await requireUserId(request);

  // GET /api/projects -> list
  if (pathname.endsWith("/api/projects") && request.method === "GET") {
    const rows = await listProjectsByUser(userId);
    return new Response(JSON.stringify({ projects: rows }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // GET /api/projects/:id -> get (owner only)
  const m = pathname.match(/\/api\/projects\/([^/]+)$/);
  if (m && request.method === "GET") {
    const id = m[1];
    const proj = await getProjectById(id);
    if (!proj || proj.user_id !== userId)
      return new Response("Not Found", { status: 404 });
    const state = await loadProjectState(id);
    return new Response(
      JSON.stringify({
        project: proj,
        timeline: state.timeline,
        textBinItems: state.textBinItems,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  // DELETE /api/projects/:id -> delete project and assets
  if (m && request.method === "DELETE") {
    const id = m[1];
    const proj = await getProjectById(id);
    if (!proj || proj.user_id !== userId)
      return new Response("Not Found", { status: 404 });

    // Delete assets belonging to this project
    try {
      const assets = await listAssetsByUser(userId, id);
      for (const a of assets) {
        // Remove file from out/
        try {
          // Validate storage_key to prevent path traversal
          if (!a.storage_key || typeof a.storage_key !== 'string') {
            console.error("Invalid storage key");
            continue;
          }
          // Sanitize the storage key to prevent path traversal
          const sanitizedKey = path.basename(a.storage_key);
          const filePath = path.resolve("out", sanitizedKey);
          if (
            filePath.startsWith(path.resolve("out")) &&
            fs.existsSync(filePath)
          ) {
            fs.unlinkSync(filePath);
          }
        } catch {
          console.error("Failed to delete asset");
        }
        await softDeleteAsset(a.id, userId);
      }
    } catch {
      console.error("Failed to delete assets");
    }

    const ok = await deleteProjectById(id, userId);
    if (!ok) return new Response("Not Found", { status: 404 });
    // remove timeline file if exists
    try {
      await fs.promises.unlink(
        path.resolve(process.env.TIMELINE_DIR || "project_data", `${id}.json`)
      );
    } catch {
      console.error("Failed to delete timeline file");
    }
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response("Not Found", { status: 404 });
}

export async function action({ request }: { request: Request }) {
  const url = new URL(request.url);
  const pathname = url.pathname;
  const userId = await requireUserId(request);

  // POST /api/projects -> create
  if (pathname.endsWith("/api/projects") && request.method === "POST") {
    const body = await request.json().catch(() => ({}));
    const name: string = String(body.name || "Untitled Project").slice(0, 120);
    const proj = await createProject({ userId, name });
    return new Response(JSON.stringify({ project: proj }), {
      status: 201,
      headers: { "Content-Type": "application/json" },
    });
  }

  // DELETE /api/projects/:id
  const delMatch = pathname.match(/\/api\/projects\/([^/]+)$/);
  if (delMatch && request.method === "DELETE") {
    const id = delMatch[1];
    const proj = await getProjectById(id);
    if (!proj || proj.user_id !== userId)
      return new Response("Not Found", { status: 404 });
    // cascade delete assets (files + soft delete rows)
    try {
      const assets = await listAssetsByUser(userId, id);
      for (const a of assets) {
        try {
          const filePath = path.resolve("out", a.storage_key);
          if (
            filePath.startsWith(path.resolve("out")) &&
            fs.existsSync(filePath)
          ) {
            fs.unlinkSync(filePath);
          }
        } catch {
          console.error("Failed to delete asset");
        }
        await softDeleteAsset(a.id, userId);
      }
    } catch {
      console.error("Failed to delete assets");
    }
    const ok = await deleteProjectById(id, userId);
    if (!ok) return new Response("Not Found", { status: 404 });
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // PATCH /api/projects/:id -> rename
  const patchMatch = pathname.match(/\/api\/projects\/([^/]+)$/);
  if (patchMatch && request.method === "PATCH") {
    const id = patchMatch[1];
    const proj = await getProjectById(id);
    if (!proj || proj.user_id !== userId)
      return new Response("Not Found", { status: 404 });
    const body = await request.json().catch(() => ({}));
    const name: string | undefined = body?.name
      ? String(body.name).slice(0, 120)
      : undefined;
    const timeline: TimelineState | undefined = body?.timeline;
    const textBinItems: MediaBinItem[] | undefined = Array.isArray(
      body?.textBinItems
    )
      ? body.textBinItems
      : undefined;
    if (!name && !timeline && !textBinItems)
      return new Response(JSON.stringify({ error: "No changes" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    // simple update
    // inline update using pg (reuse pool via repo)
    // quick import avoided; execute with small query here

    // @ts-ignore
    const { Pool } = await import("pg");
    const rawDbUrl = process.env.DATABASE_URL || "";
    let connectionString = rawDbUrl;
    try {
      const u = new URL(rawDbUrl);
      u.search = "";
      connectionString = u.toString();
    } catch {
      console.error("Invalid database URL");
    }
    const pool = new Pool({
      connectionString,
      ssl: process.env.NODE_ENV === "production" 
        ? { rejectUnauthorized: true }
        : { rejectUnauthorized: false }, // Only disable in development
    });
    try {
      if (name) {
        await pool.query(
          `update projects set name = $1, updated_at = now() where id = $2 and user_id = $3`,
          [name, id, userId]
        );
      }
    } finally {
      await pool.end();
    }
    if (timeline || textBinItems) {
      const prev = await loadProjectState(id);
      await saveProjectState(id, {
        timeline: timeline ?? prev.timeline,
        textBinItems: textBinItems ?? prev.textBinItems,
      });
    }
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response("Not Found", { status: 404 });
}



================================================
FILE: app/routes/api.storage.$.tsx
================================================
import { auth } from "~/lib/auth.server";

export async function loader({ request }: { request: Request }) {
  const url = new URL(request.url);
  const pathname = url.pathname;

  // Resolve current user id using Better Auth runtime API with cookie fallback
  async function requireUserId(req: Request): Promise<string> {
    try {
      // @ts-ignore - runtime API may not be typed
      const session = await auth.api?.getSession?.({ headers: req.headers });
      const userId: string | undefined =
        session?.user?.id ?? session?.session?.userId;
      if (userId) return String(userId);
    } catch {
      console.error("Failed to get session");
    }

    const host =
      req.headers.get("x-forwarded-host") ||
      req.headers.get("host") ||
      "localhost:5173";
    const proto =
      req.headers.get("x-forwarded-proto") ||
      (host.includes("localhost") ? "http" : "https");
    const base = `${proto}://${host}`;
    const cookie = req.headers.get("cookie") || "";
    const res = await fetch(`${base}/api/auth/session`, {
      headers: { Cookie: cookie, Accept: "application/json" },
      method: "GET",
    });
    if (!res.ok)
      throw new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    const json = await res.json().catch(() => ({}));
    const uid: string | undefined =
      json?.user?.id ||
      json?.user?.userId ||
      json?.session?.user?.id ||
      json?.session?.userId ||
      json?.data?.user?.id ||
      json?.data?.user?.userId;
    if (!uid)
      throw new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    return String(uid);
  }

  if (pathname.endsWith("/api/storage") && request.method === "GET") {
    const userId = await requireUserId(request);

    // Query the materialized view user_storage to get total_storage_bytes for this user
    // Create a transient Pool to avoid coupling to repo internals

    // @ts-ignore
    const { Pool } = await import("pg");
    const rawDbUrl = process.env.DATABASE_URL || "";
    let connectionString = rawDbUrl;
    try {
      const u = new URL(rawDbUrl);
      u.search = "";
      connectionString = u.toString();
    } catch {
      console.error("Invalid database URL");
    }
    const pool = new Pool({
      connectionString,
      ssl: process.env.NODE_ENV === "production" 
        ? { rejectUnauthorized: true }
        : { rejectUnauthorized: false }, // Only disable in development
    });

    let usedBytes = 0;
    try {
      const res = await pool.query<{ total_storage_bytes: string | number }>(
        `select total_storage_bytes from user_storage where user_id = $1 limit 1`,
        [userId]
      );
      if (res.rows.length > 0) {
        const val = res.rows[0].total_storage_bytes;
        usedBytes =
          typeof val === "string" ? parseInt(val, 10) : Number(val || 0);
        if (!Number.isFinite(usedBytes) || usedBytes < 0) usedBytes = 0;
      }
    } finally {
      await pool.end().catch(() => {});
    }

    const limitBytes = 2 * 1024 * 1024 * 1024; // 2GB default

    return new Response(JSON.stringify({ usedBytes, limitBytes }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response("Not Found", { status: 404 });
}

export async function action() {
  return new Response("Method Not Allowed", { status: 405 });
}



================================================
FILE: app/routes/home.tsx
================================================
import React, { useRef, useEffect, useCallback, useState } from "react";
import type { PlayerRef, CallbackListener } from "@remotion/player";
import {
  Play,
  Pause,
  Upload,
  Download,
  Settings,
  Plus,
  Minus,
  Scissors,
  Star,
  Bot,
  LogOut,
  Save as SaveIcon,
  ChevronRight,
  CornerUpLeft,
  CornerUpRight,
} from "lucide-react";

// Custom video controls
import { MuteButton, FullscreenButton } from "~/components/ui/video-controls";

// Components
import LeftPanel from "~/components/editor/LeftPanel";
import { VideoPlayer } from "~/video-compositions/VideoPlayer";
import { RenderStatus } from "~/components/timeline/RenderStatus";
import { TimelineRuler } from "~/components/timeline/TimelineRuler";
import { TimelineTracks } from "~/components/timeline/TimelineTracks";
import { Button } from "~/components/ui/button";
import { ProfileMenu } from "~/components/ui/ProfileMenu";
import { Badge } from "~/components/ui/badge";
import { Separator } from "~/components/ui/separator";
import { Switch } from "~/components/ui/switch";
import { Label } from "~/components/ui/label";
import { Input } from "~/components/ui/input";
import { ResizablePanelGroup, ResizablePanel, ResizableHandle } from "~/components/ui/resizable";
import { toast } from "sonner";

// Hooks
import { useTimeline } from "~/hooks/useTimeline";
import { useMediaBin } from "~/hooks/useMediaBin";
import { useRuler } from "~/hooks/useRuler";
import { useRenderer } from "~/hooks/useRenderer";

// Types and constants
import {
  FPS,
  type MediaBinItem,
  type TimelineDataItem,
  type Transition,
  type TrackState,
  type ScrubberState,
} from "~/components/timeline/types";
import { useNavigate, useParams } from "react-router";
import { ChatBox } from "~/components/chat/ChatBox";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { useAuth } from "~/hooks/useAuth";
import { AuthOverlay } from "~/components/ui/AuthOverlay";

interface Message {
  id: string;
  content: string;
  isUser: boolean;
  timestamp: Date;
}

export default function TimelineEditor() {
  const containerRef = useRef<HTMLDivElement>(null);
  const playerRef = useRef<PlayerRef>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const navigate = useNavigate();
  const params = useParams();
  const projectId = params?.id as string | undefined;
  const [projectName, setProjectName] = useState<string>("");

  const [width, setWidth] = useState<number>(1920);
  const [height, setHeight] = useState<number>(1080);
  const [isAutoSize, setIsAutoSize] = useState<boolean>(false);
  // Text fields for width/height to allow clearing while typing
  const [widthInput, setWidthInput] = useState<string>("1920");
  const [heightInput, setHeightInput] = useState<string>("1080");
  const widthInputRef = useRef<HTMLInputElement>(null);
  const heightInputRef = useRef<HTMLInputElement>(null);

  // Keep inputs in sync if width/height change elsewhere
  useEffect(() => {
    setWidthInput(String(width));
  }, [width]);
  useEffect(() => {
    setHeightInput(String(height));
  }, [height]);

  const [isChatMinimized, setIsChatMinimized] = useState<boolean>(false);

  const [chatMessages, setChatMessages] = useState<Message[]>([]);
  const [starCount, setStarCount] = useState<number | null>(null);
  // Avoid initial blank render; don't delay render on a 'mounted' gate

  const [selectedScrubberIds, setSelectedScrubberIds] = useState<string[]>([]);

  // video player media selection state
  const [selectedItem, setSelectedItem] = useState<string | null>(null);

  const {
    timeline,
    timelineWidth,
    zoomLevel,
    getPixelsPerSecond,
    getTimelineData,
    getTimelineState,
    expandTimeline,
    handleAddTrack,
    handleDeleteTrack,
    getAllScrubbers,
    handleUpdateScrubber,
    handleDeleteScrubber,
    handleDeleteScrubbersByMediaBinId,
    handleDropOnTrack,
    handleSplitScrubberAtRuler,
    handleZoomIn,
    handleZoomOut,
    handleZoomReset,
    handleGroupScrubbers,
    handleUngroupScrubber,
    handleMoveGroupToMediaBin,
    // Transition management
    handleAddTransitionToTrack,
    handleDeleteTransition,
    getConnectedElements,
    handleUpdateScrubberWithLocking,
    setTimelineFromServer,
    // undo/redo
    undo,
    redo,
    canUndo,
    canRedo,
    snapshotTimeline,
  } = useTimeline();

  const {
    mediaBinItems,
    isMediaLoading,
    getMediaBinItems,
    setTextItems,
    handleAddMediaToBin,
    handleAddTextToBin,
    handleAddGroupToMediaBin,
    contextMenu,
    handleContextMenu,
    handleDeleteFromContext,
    handleSplitAudioFromContext,
    handleCloseContextMenu,
  } = useMediaBin(handleDeleteScrubbersByMediaBinId);

  const {
    rulerPositionPx,
    isDraggingRuler,
    handleRulerDrag,
    handleRulerMouseDown,
    handleRulerMouseMove,
    handleRulerMouseUp,
    handleScroll,
    updateRulerFromPlayer,
  } = useRuler(playerRef, timelineWidth, getPixelsPerSecond());

  const { isRendering, renderStatus, handleRenderVideo } = useRenderer();

  // Wrapper function for transition drop handler to match expected interface
  const handleDropTransitionOnTrackWrapper = (transition: Transition, trackId: string, dropLeftPx: number) => {
    handleAddTransitionToTrack(trackId, transition, dropLeftPx);
  };

  // Derived values
  const timelineData = getTimelineData();
  const durationInFrames = (() => {
    let maxEndTime = 0;

    // Calculate the maximum end time from all scrubbers
    // Since overlapping scrubbers are already positioned correctly,
    // we just need the maximum end time
    timelineData.forEach((timelineItem) => {
      timelineItem.scrubbers.forEach((scrubber) => {
        if (scrubber.endTime > maxEndTime) maxEndTime = scrubber.endTime;
      });
    });

    return Math.ceil(maxEndTime * FPS);
  })();

  // Event handlers with toast notifications
  const handleAddMediaClick = useCallback(() => {
    fileInputRef.current?.click();
  }, []);

  // Hydrate project name and timeline from API
  useEffect(() => {
    (async () => {
      const id = projectId || (window.location.pathname.match(/\/project\/([^/]+)/)?.[1] ?? "");
      if (!id) return;
      const res = await fetch(`/api/projects/${encodeURIComponent(id)}`, {
        credentials: "include",
      });
      if (!res.ok) {
        navigate("/projects");
        return;
      }
      const j = await res.json();
      setProjectName(j.project?.name || "Project");
      if (j.timeline) setTimelineFromServer(j.timeline);
      // Use saved textBinItems if present, else extract from timeline
      try {
        if (Array.isArray(j.textBinItems) && j.textBinItems.length) {
          const textItems: typeof mediaBinItems = j.textBinItems.map((t: MediaBinItem) => ({
            id: t.id,
            name: t.name,
            mediaType: "text" as const,
            media_width: Number(t.media_width) || 0,
            media_height: Number(t.media_height) || 0,
            text: t.text || null,
            mediaUrlLocal: null,
            mediaUrlRemote: null,
            durationInSeconds: Number(t.durationInSeconds) || 0,
            isUploading: false,
            uploadProgress: null,
            left_transition_id: null,
            right_transition_id: null,
            groupped_scrubbers: t.groupped_scrubbers || null,
          }));
          setTextItems(textItems);
        } else {
          const perTrack = (j.timeline?.tracks || []).flatMap((t: TrackState) => t.scrubbers || []);
          const rootScrubbers = Array.isArray(j.timeline?.scrubbers) ? (j.timeline!.scrubbers as ScrubberState[]) : [];
          const allScrubbers: ScrubberState[] = [...rootScrubbers, ...perTrack];
          const textItems: typeof mediaBinItems = (allScrubbers || [])
            .filter((s: ScrubberState) => s && s.mediaType === "text" && s.text)
            .map((s: ScrubberState) => ({
              id: s.sourceMediaBinId || s.id,
              name: s.text?.textContent || "Text",
              mediaType: "text" as const,
              media_width: s.media_width || 0,
              media_height: s.media_height || 0,
              text: s.text || null,
              mediaUrlLocal: null,
              mediaUrlRemote: null,
              durationInSeconds: s.durationInSeconds || 0,
              isUploading: false,
              uploadProgress: null,
              left_transition_id: null,
              right_transition_id: null,
              groupped_scrubbers: null,
            }));
          if (textItems.length) setTextItems(textItems);
        }
      } catch {
        console.error("Failed to load project");
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [projectId]);

  // Re-link scrubbers to remote asset URLs after assets hydrate
  // Ensures images/videos/audios render after refresh (when local blob URLs are gone)
  useEffect(() => {
    if (isMediaLoading) return;
    if (!mediaBinItems || mediaBinItems.length === 0) return;

    const current = getTimelineState();
    let changed = false;

    const assetsByName = new Map(
      mediaBinItems.filter((i) => i.mediaType !== "text" && i.mediaUrlRemote).map((i) => [i.name, i]),
    );

    const newTracks = current.tracks.map((track) => ({
      ...track,
      scrubbers: track.scrubbers.map((s) => {
        if (s.mediaType === "text") return s;
        if (!s.mediaUrlRemote) {
          const match = assetsByName.get(s.name);
          if (match && match.mediaUrlRemote) {
            changed = true;
            return {
              ...s,
              mediaUrlRemote: match.mediaUrlRemote,
              sourceMediaBinId: match.id,
              media_width: match.media_width || s.media_width,
              media_height: match.media_height || s.media_height,
            };
          }
        }
        return s;
      }),
    }));

    if (changed) {
      setTimelineFromServer({ ...current, tracks: newTracks });
    }
  }, [isMediaLoading, mediaBinItems, getTimelineState, setTimelineFromServer]);

  // Save timeline to server
  const handleSaveTimeline = useCallback(async () => {
    try {
      toast.info("Saving state of the project...");
      const id = projectId || (window.location.pathname.match(/\/project\/([^/]+)/)?.[1] ?? "");
      if (!id) {
        toast.error("No project ID");
        return;
      }
      const timelineState = getTimelineState();
      // persist current text items alongside timeline
      const textItemsPayload = getMediaBinItems().filter((i) => i.mediaType === "text");
      const res = await fetch(`/api/projects/${encodeURIComponent(id)}`, {
        method: "PATCH",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          timeline: timelineState,
          textBinItems: textItemsPayload,
        }),
      });
      if (!res.ok) throw new Error(await res.text());
      toast.success("Timeline saved");
    } catch (e) {
      console.error(e);
      toast.error("Failed to save");
    }
  }, [getMediaBinItems, getTimelineState, projectId]);

  // Global Ctrl/Cmd+S to save timeline (registered after handler is defined)
  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      const isInputEl =
        ((e.target as HTMLElement)?.tagName || "").match(/^(INPUT|TEXTAREA)$/) ||
        (e.target as HTMLElement)?.isContentEditable;
      if (isInputEl) return;
      const key = e.key.toLowerCase();
      if ((e.ctrlKey || e.metaKey) && key === "s") {
        e.preventDefault();
        e.stopPropagation();
        handleSaveTimeline();
        return;
      }
      if ((e.ctrlKey || e.metaKey) && key === "z" && !e.shiftKey) {
        e.preventDefault();
        e.stopPropagation();
        undo();
        return;
      }
      if ((e.ctrlKey || e.metaKey) && key === "z" && e.shiftKey) {
        e.preventDefault();
        e.stopPropagation();
        redo();
        return;
      }
      // Delete selected item from Player (not just timeline scrubber)
      if (key === "delete") {
        if (selectedItem) {
          e.preventDefault();
          e.stopPropagation();
          handleDeleteScrubber(selectedItem);
          setSelectedItem(null);
          return;
        }
      }
    };
    window.addEventListener("keydown", onKeyDown, {
      capture: true,
    } as AddEventListenerOptions);
    return () =>
      window.removeEventListener("keydown", onKeyDown, {
        capture: true,
      } as AddEventListenerOptions);
  }, [handleSaveTimeline, undo, redo, selectedItem, handleDeleteScrubber, setSelectedItem]);

  const handleFileInputChange = useCallback(
    async (e: React.ChangeEvent<HTMLInputElement>) => {
      const files = e.target.files;
      if (files && files.length > 0) {
        const fileArray = Array.from(files);
        let successCount = 0;
        let errorCount = 0;

        // Process files sequentially to avoid overwhelming the system
        for (const file of fileArray) {
          try {
            await handleAddMediaToBin(file);
            successCount++;
          } catch (error) {
            errorCount++;
            console.error(`Failed to add ${file.name}:`, error);
          }
        }

        if (successCount > 0 && errorCount > 0) {
          toast.warning(`Imported ${successCount} file${successCount > 1 ? "s" : ""}, ${errorCount} failed`);
        } else if (errorCount > 0) {
          toast.error(`Failed to import ${errorCount} file${errorCount > 1 ? "s" : ""}`);
        }

        e.target.value = "";
      }
    },
    [handleAddMediaToBin],
  );

  const handleRenderClick = useCallback(() => {
    if (timelineData.length === 0 || timelineData.every((item) => item.scrubbers.length === 0)) {
      toast.error("No timeline to render. Add some media first!");
      return;
    }

    handleRenderVideo(getTimelineData, timeline, isAutoSize ? null : width, isAutoSize ? null : height, getPixelsPerSecond);
    toast.info("Starting render...");
  }, [handleRenderVideo, getTimelineData, timeline, width, height, isAutoSize, timelineData, getPixelsPerSecond]);

  const handleLogTimelineData = useCallback(() => {
    if (timelineData.length === 0) {
      toast.error("Timeline is empty");
      return;
    }
    console.log(JSON.stringify(getTimelineData(), null, 2));
    toast.success("Timeline data logged to console");
  }, [getTimelineData, timelineData]);

  const handleWidthChange = useCallback((newWidth: number) => {
    setWidth(newWidth);
  }, []);

  const handleHeightChange = useCallback((newHeight: number) => {
    setHeight(newHeight);
  }, []);

  const commitWidth = useCallback(() => {
    const parsed = Number(widthInput);
    const safe = !isFinite(parsed) || parsed <= 0 ? 1920 : parsed;
    setWidth(safe);
    setWidthInput(String(safe));
  }, [widthInput]);

  const commitHeight = useCallback(() => {
    const parsed = Number(heightInput);
    const safe = !isFinite(parsed) || parsed <= 0 ? 1080 : parsed;
    setHeight(safe);
    setHeightInput(String(safe));
  }, [heightInput]);

  const handleAutoSizeChange = useCallback((auto: boolean) => {
    setIsAutoSize(auto);
  }, []);

  const handleAddTextClick = useCallback(() => {
    navigate("/editor/text-editor");
  }, [navigate]);

  const handleAddTrackClick = useCallback(() => {
    handleAddTrack();
  }, [handleAddTrack]);

  // Handler for multi-selection with Ctrl+click support
  const handleSelectScrubber = useCallback((scrubberId: string | null, ctrlKey: boolean = false) => {
    if (scrubberId === null) {
      setSelectedScrubberIds([]);
      return;
    }

    if (ctrlKey) {
      setSelectedScrubberIds(prev => {
        if (prev.includes(scrubberId)) {
          // If already selected, remove it
          return prev.filter(id => id !== scrubberId);
        } else {
          // If not selected, add it
          return [...prev, scrubberId];
        }
      });
    } else {
      // Normal click - select only this scrubber
      setSelectedScrubberIds([scrubberId]);
    }
  }, []);

  const handleSplitClick = useCallback(() => {
    if (selectedScrubberIds.length === 0) {
      toast.error("Please select a scrubber to split first!");
      return;
    }

    if (selectedScrubberIds.length > 1) {
      toast.error("Please select only one scrubber to split!");
      return;
    }

    if (timelineData.length === 0 ||
      timelineData.every((item) => item.scrubbers.length === 0)) {
      toast.error("No scrubbers to split. Add some media first!");
      return;
    }

    const splitCount = handleSplitScrubberAtRuler(rulerPositionPx, selectedScrubberIds[0]);
    if (splitCount === 0) {
      toast.info("Cannot split: ruler is not positioned within the selected scrubber");
    } else {
      setSelectedScrubberIds([]); // Clear selection since original scrubber is replaced
      toast.success(`Split the selected scrubber at ruler position`);
    }
  }, [handleSplitScrubberAtRuler, rulerPositionPx, selectedScrubberIds, timelineData]);

  // Handler for grouping selected scrubbers
  const handleGroupSelected = useCallback(() => {
    if (selectedScrubberIds.length < 2) {
      toast.error("Please select at least 2 scrubbers to group!");
      return;
    }

    handleGroupScrubbers(selectedScrubberIds);
    setSelectedScrubberIds([]); // Clear selection after grouping
    toast.success(`Grouped ${selectedScrubberIds.length} scrubbers`);
  }, [selectedScrubberIds, handleGroupScrubbers]);

  // Handler for ungrouping a grouped scrubber
  const handleUngroupSelected = useCallback((scrubberId: string) => {
    handleUngroupScrubber(scrubberId);
    setSelectedScrubberIds([]); // Clear selection after ungrouping
    toast.success("Ungrouped scrubber");
  }, [handleUngroupScrubber]);

  // Handler for moving grouped scrubber to media bin
  const handleMoveToMediaBinSelected = useCallback((scrubberId: string) => {
    handleMoveGroupToMediaBin(scrubberId, handleAddGroupToMediaBin);
    setSelectedScrubberIds([]); // Clear selection after moving
  }, [handleMoveGroupToMediaBin, handleAddGroupToMediaBin]);

  const expandTimelineCallback = useCallback(() => {
    return expandTimeline(containerRef);
  }, [expandTimeline]);

  const handleScrollCallback = useCallback(() => {
    handleScroll(containerRef, expandTimelineCallback);
  }, [handleScroll, expandTimelineCallback]);

  // Play/pause controls with Player sync
  const [isPlaying, setIsPlaying] = useState(false);

  const togglePlayback = useCallback(() => {
    const player = playerRef.current;
    if (player) {
      if (player.isPlaying()) {
        player.pause();
        setIsPlaying(false);
      } else {
        player.play();
        setIsPlaying(true);
      }
    }
  }, []);

  // Sync player state with controls - simplified like original
  useEffect(() => {
    const player = playerRef.current;
    if (player) {
      const handlePlay: CallbackListener<"play"> = () => setIsPlaying(true);
      const handlePause: CallbackListener<"pause"> = () => setIsPlaying(false);
      const handleFrameUpdate: CallbackListener<"frameupdate"> = (e) => {
        // Update ruler position from player
        updateRulerFromPlayer(e.detail.frame);
      };

      player.addEventListener("play", handlePlay);
      player.addEventListener("pause", handlePause);
      player.addEventListener("frameupdate", handleFrameUpdate);

      return () => {
        player.removeEventListener("play", handlePlay);
        player.removeEventListener("pause", handlePause);
        player.removeEventListener("frameupdate", handleFrameUpdate);
      };
    }
  }, [updateRulerFromPlayer]);

  // Global spacebar play/pause functionality - like original
  useEffect(() => {
    const handleGlobalKeyPress = (event: KeyboardEvent) => {
      // Only handle spacebar when not focused on input elements
      if (event.code === "Space") {
        const target = event.target as HTMLElement;
        const isInputElement =
          target.tagName === "INPUT" ||
          target.tagName === "TEXTAREA" ||
          target.contentEditable === "true" ||
          target.isContentEditable;

        // If user is typing in an input field, don't interfere
        if (isInputElement) {
          return;
        }

        // Prevent spacebar from scrolling the page
        event.preventDefault();

        const player = playerRef.current;
        if (player) {
          if (player.isPlaying()) {
            player.pause();
          } else {
            player.play();
          }
        }
      }
    };

    // Add event listener to document for global capture
    document.addEventListener("keydown", handleGlobalKeyPress);

    return () => {
      document.removeEventListener("keydown", handleGlobalKeyPress);
    };
  }, []); // Empty dependency array since we're accessing playerRef.current directly

  // Fetch GitHub star count
  useEffect(() => {
    const fetchStarCount = async () => {
      try {
        const response = await fetch("https://api.github.com/repos/robinroy03/videoeditor");
        if (response.ok) {
          const data = await response.json();
          setStarCount(data.stargazers_count);
        }
      } catch (error) {
        console.error("Failed to fetch GitHub stars:", error);
      }
    };

    fetchStarCount();
  }, []);

  // Ruler mouse events
  useEffect(() => {
    if (isDraggingRuler) {
      const handleMouseMove = (e: MouseEvent) => handleRulerMouseMove(e, containerRef);
      document.addEventListener("mousemove", handleMouseMove);
      document.addEventListener("mouseup", handleRulerMouseUp);
      return () => {
        document.removeEventListener("mousemove", handleMouseMove);
        document.removeEventListener("mouseup", handleRulerMouseUp);
      };
    }
  }, [isDraggingRuler, handleRulerMouseMove, handleRulerMouseUp]);

  // Timeline wheel zoom functionality
  useEffect(() => {
    const timelineContainer = containerRef.current;
    if (!timelineContainer) return;

    const handleWheel = (e: WheelEvent) => {
      // Only zoom if Ctrl or Cmd is held
      if (e.ctrlKey || e.metaKey) {
        e.preventDefault();
        const scrollDirection = e.deltaY > 0 ? -1 : 1;

        if (scrollDirection > 0) {
          handleZoomIn();
        } else {
          handleZoomOut();
        }
      }
    };

    timelineContainer.addEventListener("wheel", handleWheel, {
      passive: false,
    });
    return () => {
      timelineContainer.removeEventListener("wheel", handleWheel);
    };
  }, [handleZoomIn, handleZoomOut]);

  const { user, isLoading: isAuthLoading, isSigningIn, signInWithGoogle, signOut } = useAuth();

  return (
    <div
      className="h-screen flex flex-col bg-background text-foreground"
      onPointerDown={(e: React.PointerEvent) => {
        if (e.button !== 0) {
          return;
        }
        setSelectedItem(null);
      }}>
      {/* Ultra-minimal Top Bar */}
      <header className="h-9 border-b border-border/50 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 flex items-center justify-between px-3 shrink-0">
        <div className="flex items-center gap-3">
          <KimuLogo className="h-4 w-4" />
          <h1 className="text-sm font-medium tracking-tight">Kimu Studio</h1>
        </div>

        {/* Center project name */}
        <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
          <span className="text-xs leading-none text-muted-foreground font-mono">{projectName || "Project"}</span>
        </div>

        <div className="flex items-center gap-1">
          {/* Save / Import / Export */}
          <Button
            variant="ghost"
            size="sm"
            onClick={handleSaveTimeline}
            className="h-7 px-2 text-xs"
            title="Save timeline (Ctrl/Cmd+S)">
            <SaveIcon className="h-3 w-3 mr-1" />
            Save
          </Button>

          <Button variant="ghost" size="sm" onClick={handleAddMediaClick} className="h-7 px-2 text-xs">
            <Upload className="h-3 w-3 mr-1" />
            Import
          </Button>

          <Button
            variant="default"
            size="sm"
            onClick={handleRenderClick}
            disabled={isRendering}
            className="h-7 px-2 text-xs">
            <Download className="h-3 w-3 mr-1" />
            {isRendering ? "Rendering..." : "Export"}
          </Button>

          {/* Auth status — keep avatar as the last item (right corner) */}
          {user ? (
            <ProfileMenu user={user} starCount={starCount} onSignOut={signOut} />
          ) : (
            <Button
              variant="ghost"
              size="sm"
              onClick={signInWithGoogle}
              className="h-7 px-2 text-xs ml-1"
              title="Sign in with Google">
              Sign in
            </Button>
          )}
        </div>
      </header>

      {/* Main content: Left panel full height, center preview+timeline, right chat always visible */}
      <ResizablePanelGroup direction="horizontal" className="flex-1">
        {/* Left Panel - Media Bin & Tools (full height) */}
        <ResizablePanel defaultSize={20} minSize={15} maxSize={40}>
          <div className="h-full border-r border-border">
            <LeftPanel
              mediaBinItems={mediaBinItems}
              isMediaLoading={isMediaLoading}
              onAddMedia={handleAddMediaToBin}
              onAddText={handleAddTextToBin}
              contextMenu={contextMenu}
              handleContextMenu={handleContextMenu}
              handleDeleteFromContext={handleDeleteFromContext}
              handleSplitAudioFromContext={handleSplitAudioFromContext}
              handleCloseContextMenu={handleCloseContextMenu}
            />
          </div>
        </ResizablePanel>

        <ResizableHandle withHandle />

        {/* Center Area: Preview and Timeline */}
        <ResizablePanel defaultSize={55}>
          <ResizablePanelGroup direction="vertical">
            {/* Preview Area */}
            <ResizablePanel defaultSize={65} minSize={40}>
              <div className="h-full flex flex-col bg-background">
                {/* Compact Top Bar */}
                <div className="h-8 border-b border-border/50 bg-muted/30 flex items-center justify-between px-3 shrink-0">
                  <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <span>Resolution:</span>
                    <div className="flex items-center gap-1">
                      <Input
                        type="number"
                        value={widthInput}
                        onChange={(e) => {
                          setWidthInput(e.target.value);
                          const n = Number(e.target.value);
                          if (isFinite(n) && n > 0) setWidth(n);
                        }}
                        onBlur={commitWidth}
                        onKeyDown={(e) => {
                          if (e.key === "Enter") {
                            commitWidth();
                            (e.currentTarget as HTMLInputElement).blur();
                          }
                        }}
                        disabled={isAutoSize}
                        className="h-5 w-14 text-xs px-1 border-0 bg-muted/50"
                        ref={widthInputRef}
                      />
                      <span>×</span>
                      <Input
                        type="number"
                        value={heightInput}
                        onChange={(e) => {
                          setHeightInput(e.target.value);
                          const n = Number(e.target.value);
                          if (isFinite(n) && n > 0) setHeight(n);
                        }}
                        onBlur={commitHeight}
                        onKeyDown={(e) => {
                          if (e.key === "Enter") {
                            commitHeight();
                            (e.currentTarget as HTMLInputElement).blur();
                          }
                        }}
                        disabled={isAutoSize}
                        className="h-5 w-14 text-xs px-1 border-0 bg-muted/50"
                        ref={heightInputRef}
                      />
                    </div>
                  </div>

                  <div className="flex items-center gap-1">
                    <div className="flex items-center gap-1">
                      <Switch
                        id="auto-size"
                        checked={isAutoSize}
                        onCheckedChange={handleAutoSizeChange}
                        className="scale-75"
                      />
                      <Label htmlFor="auto-size" className="text-xs">
                        Auto
                      </Label>
                    </div>

                    {!isChatMinimized && null}
                    {isChatMinimized && (
                      <>
                        <Separator orientation="vertical" className="h-4 mx-1" />
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setIsChatMinimized(false)}
                          className="h-6 w-6 p-0 text-primary"
                          title="Open Chat">
                          <KimuLogo className="h-3 w-3" />
                        </Button>
                      </>
                    )}
                  </div>
                </div>

                {/* Video Preview */}
                <div
                  className={
                    "flex-1 bg-zinc-200/70 dark:bg-zinc-900 " +
                    "flex flex-col items-center justify-center p-3 border border-border/50 rounded-lg overflow-hidden shadow-2xl relative"
                  }>
                  <div className="flex-1 flex items-center justify-center w-full">
                    <VideoPlayer
                      timelineData={timelineData}
                      durationInFrames={durationInFrames}
                      ref={playerRef}
                      compositionWidth={isAutoSize ? null : width}
                      compositionHeight={isAutoSize ? null : height}
                      timeline={timeline}
                      handleUpdateScrubber={handleUpdateScrubber}
                      selectedItem={selectedItem}
                      setSelectedItem={setSelectedItem}
                      getPixelsPerSecond={getPixelsPerSecond}
                    />
                  </div>

                  {/* Custom Video Controls - Below Player */}
                  <div className="w-full flex items-center justify-center gap-2 mt-3 px-4">
                    {/* Left side controls */}
                    <div className="flex items-center gap-1">
                      <MuteButton playerRef={playerRef} />
                    </div>

                    {/* Center play/pause button */}
                    <div className="flex items-center">
                      <Button variant="ghost" size="sm" onClick={togglePlayback} className="h-6 w-6 p-0">
                        {isPlaying ? <Pause className="h-3 w-3" /> : <Play className="h-3 w-3" />}
                      </Button>
                    </div>

                    {/* Right side controls */}
                    <div className="flex items-center gap-1">
                      <FullscreenButton playerRef={playerRef} />
                    </div>
                  </div>
                </div>
              </div>
            </ResizablePanel>

            <ResizableHandle withHandle />

            {/* Timeline Area */}
            <ResizablePanel defaultSize={35} minSize={25}>
              <div className="h-full flex flex-col bg-muted/20">
                <div className="h-8 border-b border-border/50 bg-muted/30 flex items-center justify-between px-3 shrink-0">
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-medium">Timeline</span>
                    <Badge variant="outline" className="text-xs h-4 px-1.5 font-mono">
                      {Math.round(((durationInFrames || 0) / FPS) * 10) / 10}s
                    </Badge>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={undo}
                      disabled={!canUndo}
                      className="h-6 w-6 p-0"
                      title="Undo (Ctrl/Cmd+Z)">
                      <CornerUpLeft className="h-3 w-3" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={redo}
                      disabled={!canRedo}
                      className="h-6 w-6 p-0"
                      title="Redo (Ctrl/Cmd+Shift+Z)">
                      <CornerUpRight className="h-3 w-3" />
                    </Button>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="flex items-center">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={handleZoomOut}
                        className="h-6 w-6 p-0 text-xs"
                        title="Zoom Out">
                        <Minus className="h-3 w-3" />
                      </Button>
                      <Badge
                        variant="secondary"
                        className="text-xs h-4 px-1.5 font-mono cursor-pointer hover:bg-secondary/80 transition-colors"
                        onClick={handleZoomReset}
                        title="Click to reset zoom to 100%">
                        {Math.round(zoomLevel * 100)}%
                      </Badge>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={handleZoomIn}
                        className="h-6 w-6 p-0 text-xs"
                        title="Zoom In">
                        <Plus className="h-3 w-3" />
                      </Button>
                    </div>
                    <Separator orientation="vertical" className="h-4 mx-1" />
                    <Button variant="ghost" size="sm" onClick={handleAddTrackClick} className="h-6 px-2 text-xs">
                      <Plus className="h-3 w-3 mr-1" />
                      Track
                    </Button>
                    <Separator orientation="vertical" className="h-4 mx-1" />
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={handleSplitClick}
                      className="h-6 px-2 text-xs"
                      title="Split selected scrubber at ruler position">
                      <Scissors className="h-3 w-3 mr-1" />
                      Split
                    </Button>
                    <Separator orientation="vertical" className="h-4 mx-1" />
                    <Button variant="ghost" size="sm" onClick={handleLogTimelineData} className="h-6 px-2 text-xs">
                      <Settings className="h-3 w-3 mr-1" />
                      Debug
                    </Button>
                  </div>
                </div>

                <TimelineRuler
                  timelineWidth={timelineWidth}
                  rulerPositionPx={rulerPositionPx}
                  containerRef={containerRef}
                  onRulerDrag={handleRulerDrag}
                  onRulerMouseDown={handleRulerMouseDown}
                  pixelsPerSecond={getPixelsPerSecond()}
                  scrollLeft={containerRef.current?.scrollLeft || 0}
                />

                <TimelineTracks
                  timeline={timeline}
                  timelineWidth={timelineWidth}
                  rulerPositionPx={rulerPositionPx}
                  containerRef={containerRef}
                  onScroll={handleScrollCallback}
                  onDeleteTrack={handleDeleteTrack}
                  onUpdateScrubber={handleUpdateScrubberWithLocking}
                  onDeleteScrubber={handleDeleteScrubber}
                  onDropOnTrack={handleDropOnTrack}
                  onDropTransitionOnTrack={handleDropTransitionOnTrackWrapper}
                  onDeleteTransition={handleDeleteTransition}
                  getAllScrubbers={getAllScrubbers}
                  expandTimeline={expandTimelineCallback}
                  onRulerMouseDown={handleRulerMouseDown}
                  pixelsPerSecond={getPixelsPerSecond()}
                  selectedScrubberIds={selectedScrubberIds}
                  onSelectScrubber={handleSelectScrubber}
                  onGroupScrubbers={handleGroupSelected}
                  onUngroupScrubber={handleUngroupSelected}
                  onMoveToMediaBin={handleMoveToMediaBinSelected}
                  onBeginScrubberTransform={snapshotTimeline}
                />
              </div>
            </ResizablePanel>
          </ResizablePanelGroup>
        </ResizablePanel>

        {/* Right Panel - Chat (toggleable) */}
        {!isChatMinimized && (
          <>
            <ResizableHandle withHandle />
            <ResizablePanel defaultSize={20} minSize={15} maxSize={35}>
              <div className="h-full border-l border-border">
                <ChatBox
                  mediaBinItems={mediaBinItems}
                  handleDropOnTrack={handleDropOnTrack}
                  isMinimized={false}
                  onToggleMinimize={() => setIsChatMinimized(true)}
                  messages={chatMessages}
                  onMessagesChange={setChatMessages}
                  timelineState={timeline}
                  handleUpdateScrubber={handleUpdateScrubberWithLocking}
                  handleDeleteScrubber={handleDeleteScrubber}
                />
              </div>
            </ResizablePanel>
          </>
        )}
      </ResizablePanelGroup>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="video/*,image/*,audio/*"
        multiple
        className="hidden"
        onChange={handleFileInputChange}
      />

      {/* Render Status as Toast */}
      {renderStatus && (
        <div className="fixed bottom-4 right-4 z-50">
          <RenderStatus renderStatus={renderStatus} />
        </div>
      )}

      {/* Blocker overlay for unauthenticated users */}
      {!isAuthLoading && !user && (
        <AuthOverlay isLoading={isAuthLoading} isSigningIn={isSigningIn} onSignIn={signInWithGoogle} />
      )}
    </div>
  );
}



================================================
FILE: app/routes/learn.tsx
================================================
import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
  Sequence,
} from 'remotion';
import { Player } from '@remotion/player';
import { createTikTokStyleCaptions } from '@remotion/captions';

type Caption = {
  text: string;
  startMs: number;
  endMs: number;
  timestampMs: number | null;
  confidence: number | null;
};

type CaptionPageData = {
  text: string;
  startMs: number;
  durationMs: number;
  tokens: Array<{
    text: string;
    fromMs: number;
    toMs: number;
  }>;
};


const captions: Caption[] = [
  {
    text: 'Hi,',
    startMs: 0,
    endMs: 500,
    timestampMs: 250,
    confidence: 0.95,
  },
  {
    text: ' Welcome efd sdf sd fsd fsd fsd f sf sdf sd fsd fsd fs d',
    startMs: 500,
    endMs: 800,
    timestampMs: 650,
    confidence: 0.98,
  },
  {
    text: ' to',
    startMs: 800,
    endMs: 1100,
    timestampMs: 950,
    confidence: 0.99,
  },
  {
    text: ' Kimu',
    startMs: 1100,
    endMs: 1800,
    timestampMs: 1450,
    confidence: 0.97,
  },
  {
    text: ' world',
    startMs: 1800,
    endMs: 2200,
    timestampMs: 2000,
    confidence: 0.96,
  },
  {
    text: ' of',
    startMs: 2200,
    endMs: 2500,
    timestampMs: 2350,
    confidence: 0.99,
  },
  {
    text: ' Remotion',
    startMs: 2500,
    endMs: 3200,
    timestampMs: 2850,
    confidence: 0.98,
  },
  {
    text: ' video',
    startMs: 3200,
    endMs: 3800,
    timestampMs: 3500,
    confidence: 0.97,
  },
  {
    text: ' editing!',
    startMs: 3800,
    endMs: 4500,
    timestampMs: 4150,
    confidence: 0.95,
  },
  {
    text: ' end',
    startMs: 7000,
    endMs: 8000,
    timestampMs: 7350,
    confidence: 0.95,
  },
];

// Create TikTok-style caption pages
const { pages } = createTikTokStyleCaptions({
  captions,
  combineTokensWithinMilliseconds: 1200, // Group words within 1.2 seconds
});

interface CaptionPageProps {
  page: CaptionPageData;
}

const CaptionPage = ({ page }: CaptionPageProps) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Animation for the page entrance
  const pageProgress = spring({
    frame,
    fps,
    config: {
      damping: 15,
      stiffness: 200,
    },
  });

  const opacity = interpolate(pageProgress, [0, 0.2, 1], [0, 1, 1]);

  const findPositionForToken = (token: { text: string; fromMs: number; toMs: number }) => {
    const byTime = captions.find(
      (c) => Math.abs(c.startMs - token.fromMs) <= 50 && Math.abs(c.endMs - token.toMs) <= 50
    );
    if (byTime) {
      return { left: '50%', top: '80%' };
    }
    const byText = captions.find((c) => c.text.trim() === token.text.trim());
    return { left: '50%', top: '80%' };
  };

  return (
    <div
      style={{
        position: 'absolute',
        inset: 0,
        opacity,
        fontFamily: 'Arial, sans-serif',
        zIndex: 10, // Ensure CaptionPage is above other elements
      }}
    >
      {/* Render each token with individual animation */}
      {page.tokens.map((token, index) => {
        // Inside a <Sequence />, `frame` starts at 0 at `page.startMs`.
        // Make token timing relative to the page start to avoid double-offsets.
        const tokenRelativeStartFrame = ((token.fromMs - page.startMs) / 1000) * fps;
        const tokenProgress = spring({
          frame: frame - tokenRelativeStartFrame,
          fps,
          config: {
            damping: 12,
            stiffness: 150,
          },
        });

        const tokenOpacity = interpolate(tokenProgress, [0, 0.3], [0, 1], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        });

        const tokenScale = interpolate(tokenProgress, [0, 0.3], [0.9, 1], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        });

        const { left, top } = findPositionForToken(token);

        return (
          <span
            key={`token-${page.startMs}-${token.fromMs}-${token.toMs}`}
            style={{
              position: 'absolute',
              left,
              top,
              opacity: tokenOpacity,
              transform: `translate(-50%, -50%) scale(${tokenScale})`,
              display: 'inline-block',
              transition: 'transform 0.1s ease-out',
              fontSize: '3rem',
              fontWeight: 'bold',
              color: '#ffffff',
              textShadow: '2px 2px 4px rgba(0, 0, 0, 0.8)',
            }}
            onMouseEnter={() => {
              console.log('mouse entered token', token.text);
            }}
            onMouseLeave={() => {
              console.log('mouse left token', token.text);
            }}
          >
            {token.text}
          </span>
        );
      })}
    </div>
  );
};

const TikTokStyleCaptionsExample: React.FC = () => {
  const { fps } = useVideoConfig();

  console.log('pages', JSON.stringify(pages, null, 2));
  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      {/* Render each caption page as a sequence */}
      {pages.map((page: CaptionPageData, index: number) => (
        <Sequence
          key={`page-${page.startMs}`}
          from={(page.startMs / 1000) * fps}
          durationInFrames={(page.durationMs / 1000) * fps}
        >
          <CaptionPage page={page} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

// Additional example showing different caption styles
const AlternativeCaptionStyle: React.FC<CaptionPageProps> = ({ page }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <div
      style={{
        position: 'absolute',
        top: '10%',
        left: '50%',
        transform: 'translateX(-50%)',
        fontSize: '2rem',
        fontWeight: 'bold',
        textAlign: 'center',
        WebkitTextStroke: '1px black',
        // Allow wrapping within a constrained width
        maxWidth: '90%',
        whiteSpace: 'pre-wrap',
        wordBreak: 'break-word',
        overflowWrap: 'anywhere',
        fontFamily: 'Impact, Arial Black, sans-serif',
        letterSpacing: '2px',
        zIndex: 5, // Lower z-index than CaptionPage
      }}
    >
      {page.tokens.map((token, index) => {
        const tokenRelativeStartFrame = ((token.fromMs - page.startMs) / 1000) * fps;
        const isActive = frame >= tokenRelativeStartFrame;

        return (
          <span
            key={`alt-token-${token.fromMs}`}
            style={{
              opacity: isActive ? 1 : 0.3,
              color: isActive ? '#ffff00' : '#ffffff',
              // color: isActive ? 'red' : 'white',
              textShadow: isActive
                ? '0 0 10px #ffff00, 2px 2px 4px rgba(0, 0, 0, 0.8)'
                : '2px 2px 4px rgba(0, 0, 0, 0.8)',
              transition: 'all 0.2s ease-out',
            }}
          >
            {token.text}
          </span>
        );
      })}
    </div>
  );
};

// Glassy subtitles-only composition (bottom overlay)
const GlassySubtitlePage = ({ page }: CaptionPageProps) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const containerStyle: React.CSSProperties = {
    position: 'absolute',
    left: '50%',
    bottom: '8%',
    transform: 'translateX(-50%)',
    zIndex: 20,
    display: 'flex',
    flexWrap: 'wrap',
    gap: '0.4rem',
    justifyContent: 'center',
    alignItems: 'center',
    padding: '0.6rem 0.8rem',
    borderRadius: 18,
    backdropFilter: 'blur(12px) saturate(160%)',
    WebkitBackdropFilter: 'blur(12px) saturate(160%)',
    // background: 'rgba(255, 255, 255, 0.14)',
    // background: 'red',
    border: '1px solid rgba(255, 255, 255, 0.22)',
    boxShadow:
      '0 10px 30px rgba(0, 0, 0, 0.25), inset 0 0 0 1px rgba(255, 255, 255, 0.06)',
  };

  const tokenBaseStyle: React.CSSProperties = {
    fontSize: 'clamp(18px, 3.2vw, 36px)',
    fontWeight: 800,
    lineHeight: 1.2,
    letterSpacing: '0.6px',
    padding: '0.1rem 0.2rem',
    color: 'transparent',
    // color: 'red',
    backgroundImage:
      'linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.78) 100%)',
    WebkitBackgroundClip: 'text',
    backgroundClip: 'text',
    textShadow: '0 2px 10px rgba(0,0,0,0.45), 0 0 1px rgba(255,255,255,0.4)',
    whiteSpace: 'pre-wrap',
  };

  const tokenInactiveStyle: React.CSSProperties = {
    opacity: 0.35,
    filter: 'blur(0.2px)',
  };

  return (
    <div style={containerStyle}>
      {page.tokens.map((token) => {
        const tokenRelativeStartFrame = ((token.fromMs - page.startMs) / 1000) * fps;
        const isActive = frame >= tokenRelativeStartFrame;
        return (
          <span
            key={`glass-token-${page.startMs}-${token.fromMs}-${token.toMs}`}
            style={{ ...tokenBaseStyle, ...(isActive ? {} : tokenInactiveStyle) }}
          >
            {token.text}
          </span>
        );
      })}
    </div>
  );
};

const GlassySubtitlesExample: React.FC = () => {
  const { fps } = useVideoConfig();
  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #0f2027 0%, #203a43 50%, #2c5364 100%)',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      {pages.map((page: CaptionPageData) => (
        <Sequence
          key={`glass-page-${page.startMs}`}
          from={(page.startMs / 1000) * fps}
          durationInFrames={(page.durationMs / 1000) * fps}
        >
          <GlassySubtitlePage page={page} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

// New composition: Alternates caption style per page
const AlternatingCaptionsExample: React.FC = () => {
  const { fps } = useVideoConfig();

  return (
    <AbsoluteFill
      style={{
        background:
          'linear-gradient(135deg, #1f2937 0%, #111827 100%)',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      {pages.map((page: CaptionPageData, index: number) => (
        <Sequence
          key={`alternating-page-${page.startMs}`}
          from={(page.startMs / 1000) * fps}
          durationInFrames={(page.durationMs / 1000) * fps}
        >
          {index % 3 === 0 ? (
            <GlassySubtitlePage page={page} />
          ) : index % 3 === 1 ? (
            <AlternativeCaptionStyle page={page} />
          ) : (
            <CaptionPage page={page} />
          )}
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

// Composition showcasing different caption configurations
export const CaptionsShowcase: React.FC = () => {
  const { fps } = useVideoConfig();

  // Create pages with different timing for comparison
  const quickPages = createTikTokStyleCaptions({
    captions,
    combineTokensWithinMilliseconds: 600, // Faster word switching
  }).pages;

  const slowPages = createTikTokStyleCaptions({
    captions,
    combineTokensWithinMilliseconds: 2000, // Slower, more words per page
  }).pages;

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(45deg, #1e3c72 0%, #2a5298 100%)',
      }}
    >
      {/* Main TikTok-style captions */}
      {pages.map((page: CaptionPageData, index: number) => (
        <Sequence
          key={`main-${page.startMs}`}
          from={(page.startMs / 1000) * fps}
          durationInFrames={(page.durationMs / 1000) * fps}
        >
          <CaptionPage page={page} />
        </Sequence>
      ))}

      {/* Alternative style captions */}
      {quickPages.map((page: CaptionPageData, index: number) => (
        <Sequence
          key={`alt-${page.startMs}`}
          from={(page.startMs / 1000) * fps}
          durationInFrames={(page.durationMs / 1000) * fps}
        >
          <AlternativeCaptionStyle page={page} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

// Player component to view the captions
const CaptionsPlayer = () => {
  const videoConfig = {
    id: 'TikTokCaptions',
    width: 1080,
    height: 1920, // Vertical video format like TikTok
    fps: 30,
    durationInFrames: 350, // 5 seconds at 30fps
  };

  return (
    <div style={{ padding: '2rem', backgroundColor: '#f0f0f0', minHeight: '100vh' }}>
      <h1 style={{ textAlign: 'center', marginBottom: '2rem', color: '#333' }}>
        TikTok-Style Captions Demo
      </h1>

      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        flexDirection: 'column',
        gap: '2rem'
      }}>
        {/* Main Player */}
        <div style={{
          border: '2px solid #333',
          borderRadius: '12px',
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)'
        }}>
          <Player
            component={TikTokStyleCaptionsExample}
            durationInFrames={videoConfig.durationInFrames}
            compositionWidth={videoConfig.width}
            compositionHeight={videoConfig.height}
            fps={videoConfig.fps}
            style={{
              width: '300px',
              height: '533px', // Maintain aspect ratio
            }}
            controls
            loop
          />
        </div>

        {/* Alternative showcase player */}
        <div style={{
          border: '2px solid #333',
          borderRadius: '12px',
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)'
        }}>
          <Player
            component={CaptionsShowcase}
            durationInFrames={videoConfig.durationInFrames}
            compositionWidth={videoConfig.width}
            compositionHeight={videoConfig.height}
            fps={videoConfig.fps}
            style={{
              width: '300px',
              height: '533px', // Maintain aspect ratio
            }}
            controls
            loop
          />
        </div>

        {/* Glassy subtitles player */}
        <div style={{
          border: '2px solid #333',
          borderRadius: '12px',
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)'
        }}>
          <Player
            component={GlassySubtitlesExample}
            durationInFrames={videoConfig.durationInFrames}
            compositionWidth={videoConfig.width}
            compositionHeight={videoConfig.height}
            fps={videoConfig.fps}
            style={{
              width: '300px',
              height: '533px',
            }}
            controls
            loop
          />
        </div>

        {/* Alternating styles player (Glassy → Alternate → Normal → repeat) */}
        <div style={{
          border: '2px solid #333',
          borderRadius: '12px',
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)'
        }}>
          <Player
            component={AlternatingCaptionsExample}
            durationInFrames={videoConfig.durationInFrames}
            compositionWidth={videoConfig.width}
            compositionHeight={videoConfig.height}
            fps={videoConfig.fps}
            style={{
              width: '300px',
              height: '533px',
            }}
            controls
            loop
          />
        </div>
      </div>
    </div>
  );
};

export default CaptionsPlayer;


================================================
FILE: app/routes/login.tsx
================================================
import React from "react";
import { auth } from "~/lib/auth.server";
import { useAuth } from "~/hooks/useAuth";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { Clapperboard, Wand2, Scissors } from "lucide-react";
import { FaGoogle } from "react-icons/fa";

export async function loader({ request }: { request: Request }) {
  // If already authenticated, redirect to projects
  try {
    const session = await auth.api?.getSession?.({ headers: request.headers });
    const uid: string | undefined =
      session?.user?.id || session?.session?.userId;
    if (uid)
      return new Response(null, {
        status: 302,
        headers: { Location: "/projects" },
      });
  } catch {
    console.error("Login failed");
  }
  return null;
}

export default function LoginPage() {
  const { isSigningIn, signInWithGoogle } = useAuth();

  return (
    <div className="relative min-h-screen w-full overflow-hidden bg-background text-foreground">
      {/* Animated timeline grid background */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 opacity-[0.08]"
        style={{
          backgroundImage:
            "repeating-linear-gradient(0deg, rgba(255,255,255,0.6) 0 1px, transparent 1px 40px), repeating-linear-gradient(90deg, rgba(255,255,255,0.6) 0 1px, transparent 1px 72px)",
          backgroundSize: "auto",
        }}
      />

      {/* Accent radial glows (multi-hue) */}
      <div aria-hidden className="pointer-events-none absolute inset-0 -z-10">
        <div className="absolute -left-32 -top-24 h-[48vw] w-[48vw] rounded-full blur-3xl mix-blend-screen bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.28),transparent_65%)]" />
        <div className="absolute -right-24 top-[-10%] h-[40vw] w-[40vw] rounded-full blur-3xl mix-blend-screen bg-[radial-gradient(circle_at_center,rgba(236,72,153,0.20),transparent_65%)]" />
        <div className="absolute -left-20 bottom-[-10%] h-[38vw] w-[38vw] rounded-full blur-3xl mix-blend-screen bg-[radial-gradient(circle_at_center,rgba(34,197,94,0.18),transparent_65%)]" />
        <div className="absolute -right-36 bottom-[-12%] h-[46vw] w-[46vw] rounded-full blur-3xl mix-blend-screen bg-[radial-gradient(circle_at_center,rgba(56,189,248,0.20),transparent_65%)]" />
      </div>

      {/* Sweeping playhead */}
      <div
        className="absolute inset-y-0 -z-10"
        style={{ animation: "sweep 14s linear infinite" }}
      >
        <div className="absolute top-0 bottom-0 w-px bg-primary/70" />
        <div className="absolute top-0 bottom-0 w-[3px] translate-x-[-1px] bg-primary/30 blur-[1px]" />
      </div>

      {/* Floating editor artifacts */}
      <Clapperboard
        aria-hidden
        className="absolute left-10 top-16 h-6 w-6 text-primary/30 animate-[float_8s_ease-in-out_infinite]"
      />
      <Wand2
        aria-hidden
        className="absolute right-12 top-24 h-5 w-5 text-primary/30 animate-[float_9s_ease-in-out_infinite] [animation-delay:2s]"
      />
      <Scissors
        aria-hidden
        className="absolute left-1/2 bottom-16 h-5 w-5 text-primary/30 animate-[float_10s_ease-in-out_infinite] [animation-delay:1s]"
      />

      {/* Centerpiece orb */}
      <main className="relative grid place-items-center px-4 min-h-screen">
        <div className="relative grid place-items-center">
          <div className="relative h-80 w-80 rounded-full border border-border/40 bg-background/25 backdrop-blur-2xl transition-transform duration-700 will-change-transform hover:scale-[1.02]">
            {/* Outer halo */}
            <div
              className="pointer-events-none absolute -inset-6 -z-10 rounded-full blur-3xl opacity-70"
              style={{
                background:
                  "radial-gradient(circle at 50% 50%, rgba(99,102,241,0.28), transparent 55%)",
                animation: "pulse 6s ease-in-out infinite",
              }}
            />
            {/* Soft inner glow */}
            <div className="absolute inset-0 rounded-full bg-[radial-gradient(closest-side,rgba(255,255,255,0.16),transparent_70%)]" />
            {/* Rotating multi-hue sheen (single cycle) */}
            <div
              className="absolute inset-0 rounded-full opacity-80"
              style={{
                background:
                  "conic-gradient(from_0deg, rgba(99,102,241,0.16), rgba(236,72,153,0.10), rgba(56,189,248,0.12), rgba(34,197,94,0.10), rgba(99,102,241,0.16))",
                animation: "spin 28s linear infinite",
              }}
            />
            {/* Concentric ring lines (static) */}
            <div className="absolute inset-0 rounded-full opacity-25 [mask-image:radial-gradient(circle,transparent_56%,black_60%,black_72%,transparent_76%)] bg-[conic-gradient(from_0deg,rgba(255,255,255,0.22),transparent_10%,transparent_38%,rgba(255,255,255,0.22),transparent_60%,transparent_88%,rgba(255,255,255,0.22))]" />
            {/* Specular highlight */}
            <div className="absolute inset-0 rounded-full bg-[radial-gradient(circle_at_50%_35%,rgba(255,255,255,0.10),transparent_55%)]" />
            <div className="relative z-10 grid h-full w-full place-items-center">
              <KimuLogo className="h-14 w-14" />
            </div>
          </div>
          <h1 className="mt-6 text-lg font-semibold tracking-tight">
            Welcome to Kimu
          </h1>
          <p className="mt-1 text-xs text-muted-foreground">
            Cinematic editing, reimagined.
          </p>
          <div className="mt-6 w-full max-w-sm">
            <button
              onClick={signInWithGoogle}
              disabled={!!isSigningIn}
              className="w-full inline-flex items-center justify-center gap-2 h-10 px-4 rounded-md bg-foreground text-background text-sm"
            >
              {isSigningIn ? (
                <>
                  <svg className="h-4 w-4 animate-spin" viewBox="0 0 24 24">
                    <circle
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                      fill="none"
                      opacity=".25"
                    />
                    <path
                      d="M22 12a10 10 0 0 1-10 10"
                      stroke="currentColor"
                      strokeWidth="4"
                      fill="none"
                    />
                  </svg>
                  Signing in...
                </>
              ) : (
                <>
                  <FaGoogle className="h-4 w-4" />
                  Continue with Google
                </>
              )}
            </button>
          </div>
          <p className="mt-3 text-[11px] text-muted-foreground">
            We never post on your behalf.
          </p>
        </div>
      </main>

      {/* Local keyframes and bokeh */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 opacity-[0.05]"
        style={{
          backgroundImage:
            "repeating-radial-gradient(circle at 20% 30%, rgba(255,255,255,0.5) 0 1px, transparent 2px 28px), repeating-radial-gradient(circle at 80% 60%, rgba(255,255,255,0.5) 0 1px, transparent 2px 36px)",
        }}
      />
      <style>{`
        @keyframes sweep { 0% { left: -10%; } 100% { left: 110%; } }
        @keyframes float { 0%, 100% { transform: translateY(0px); } 50% { transform: translateY(-6px); } }
        @keyframes pulse { 0%, 100% { opacity: .55; transform: scale(0.98); } 50% { opacity: .85; transform: scale(1.03); } }
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}



================================================
FILE: app/routes/marketplace.tsx
================================================
import React from "react";

export default function MarketplaceComingSoon() {
  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-background text-foreground">
      <div className="text-center p-8">
        <h1 className="text-4xl font-extrabold tracking-tight mb-2">
          Marketplace
        </h1>
        <p className="text-muted-foreground">Coming soon...</p>
      </div>
    </div>
  );
}



================================================
FILE: app/routes/privacy.tsx
================================================
import * as React from "react";
import {
  FileText,
  Calendar,
  ShieldCheck,
  Lock,
  Server,
  Database,
  Cloud,
  KeyRound,
  BarChart3,
  Users,
  Download,
  Trash2,
  Github,
} from "lucide-react";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { GlowingEffect } from "~/components/ui/glowing-effect";

export default function Privacy() {
  return (
    <div className="min-h-screen bg-background text-foreground pt-20">
      {/* Hero / Masthead */}
      <div className="relative overflow-hidden">
        <div aria-hidden className="pointer-events-none absolute inset-0 -z-10">
          <div className="absolute -top-32 right-1/4 w-[40rem] h-[40rem] rounded-full bg-[radial-gradient(circle,rgba(99,102,241,0.22),transparent_60%)] blur-3xl" />
          <div className="absolute -bottom-32 left-1/4 w-[40rem] h-[40rem] rounded-full bg-[radial-gradient(circle,rgba(16,185,129,0.18),transparent_60%)] blur-3xl" />
        </div>
        <div className="max-w-5xl mx-auto px-6 pt-10 pb-6 text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-border/30 text-xs text-muted-foreground mb-4">
            <FileText className="w-3.5 h-3.5" /> Privacy & Data Transparency
          </div>
          <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight">
            Your data. Your rules.
          </h1>
          <p className="mt-3 text-sm md:text-base text-muted-foreground">
            Crystal-clear privacy with open-source transparency and explicit
            data boundaries.
          </p>
          <div className="mt-4 flex items-center justify-center gap-4 text-xs text-muted-foreground">
            <span className="inline-flex items-center gap-1">
              <Calendar className="w-4 h-4" /> Updated 30th August 2025
            </span>
            <span className="w-1 h-1 rounded-full bg-current/60" />
            <span>Version 2.0</span>
          </div>
        </div>
      </div>

      {/* Document Container */}
      <div className="max-w-5xl mx-auto px-6 pb-20">
        <div className="relative rounded-2xl border border-border/30 bg-background/80 shadow-2xl p-6 md:p-10">
          <GlowingEffect
            disabled={false}
            spread={44}
            proximity={72}
            glow
            borderWidth={1}
            hoverBorderWidth={3}
          />

          {/* Document Header */}
          <div className="text-center mb-10 pb-6 border-b border-border/20">
            <div className="flex items-center justify-center gap-3 mb-2">
              <KimuLogo className="w-6 h-6 text-foreground" />
              <span className="text-sm font-semibold tracking-tight">
                Kimu Privacy Policy
              </span>
            </div>
            <h2 className="text-2xl md:text-3xl font-extrabold tracking-tight">
              How we handle your data
            </h2>
            <div className="mt-4 mx-auto max-w-3xl rounded-lg border border-border/30 bg-muted/5 px-4 py-3 text-xs font-mono text-muted-foreground text-left">
              Kimu ("we," "our," or "us") is committed to protecting your
              privacy. This Privacy Policy explains how we collect, use,
              disclose, and safeguard your information when you use our video
              editing application and related services.
            </div>
          </div>

          {/* Document Content */}
          <div className="prose prose-slate dark:prose-invert max-w-none">
            <div className="space-y-8 text-foreground leading-relaxed">
              {/* 1. Applicability */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  1. Applicability & Consent
                </h2>
                <div className="space-y-2 ml-8">
                  <p className="text-sm text-muted-foreground">
                    This Privacy Policy applies to our online services and is
                    valid for visitors and users of our website and web editor
                    with regards to information that they share with and/or
                    collect in Kimu. This policy does not apply to information
                    collected offline or via channels other than this website
                    and app.
                  </p>
                  <p className="text-sm text-muted-foreground">
                    By using our website or editor, you hereby consent to this
                    Privacy Policy and agree to its terms. If you have
                    additional questions or require more information, contact
                    us.
                  </p>
                </div>
              </section>

              {/* 2. Information Collection */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  2. Information We Collect
                </h2>
                <div className="space-y-6 ml-11">
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      2.1 Personal Information
                    </h3>
                    <p className="text-sm text-muted-foreground mb-3">
                      We collect the minimum required, and it will be clear at
                      the point of collection:
                    </p>
                    <ul className="space-y-1 text-sm text-muted-foreground ml-6 list-disc">
                      <li>Email address (for account access)</li>
                      <li>Profile info from Google OAuth</li>
                      <li>Preferences and settings stored in Supabase</li>
                    </ul>
                  </div>

                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      2.2 Video Content
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Projects can be <strong>local</strong> or{" "}
                      <strong>cloud</strong>:
                    </p>
                    <ul className="space-y-1 text-sm text-muted-foreground ml-6 list-disc">
                      <li>
                        Local projects keep media on your device (IndexedDB /
                        disk).
                      </li>
                      <li>
                        Cloud projects store media securely on our Hetzner VPS
                        for collaboration and access.
                      </li>
                      <li>
                        Project metadata (names, timelines, settings) is stored
                        in Supabase.
                      </li>
                    </ul>
                  </div>

                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      2.3 Additional Details You May Provide
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      If you contact us directly, we may receive your name,
                      email, phone number, and message contents. During account
                      registration or billing, we may request optional details
                      like company name or address.
                    </p>
                  </div>
                </div>
              </section>

              {/* 3. Data Processing */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  3. How We Process Your Data
                </h2>
                <div className="space-y-6 ml-11">
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      3.1 Local Processing
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Editing and preview are real-time in your browser. For
                      local projects, media never leaves your device.
                    </p>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      3.2 Account Management
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      We use your email address solely for account
                      authentication, password recovery, and important service
                      notifications.
                    </p>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      3.3 Cloud Collaboration
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Cloud projects are required for multiplayer. Assets are
                      stored securely and only accessible to members granted
                      access.
                    </p>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      3.4 How We Use Information
                    </h3>
                    <ul className="space-y-1 text-sm text-muted-foreground ml-6 list-disc">
                      <li>Provide, operate, and maintain the service</li>
                      <li>Improve and expand features</li>
                      <li>Understand and analyze aggregated usage</li>
                      <li>Develop new functionality</li>
                      <li>Send account-related emails</li>
                      <li>Prevent fraud and abuse</li>
                    </ul>
                  </div>
                </div>
              </section>

              {/* 4. Data Storage */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  4. Data Storage and Security
                </h2>
                <div className="space-y-6 ml-11">
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      4.1 Local Storage
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Project files, video assets, and editing history are
                      stored locally in your browser's IndexedDB. This data
                      remains under your control.
                    </p>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      4.2 Security Measures
                    </h3>
                    <ul className="space-y-1 text-sm text-muted-foreground ml-6 list-disc">
                      <li>All server communications use HTTPS</li>
                      <li>Account data stored with industry best practices</li>
                      <li>Regular security audits and updates</li>
                    </ul>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold mb-2">
                      4.3 Enforcement & Safety
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Uploads are private and secure. Assets violating Terms of
                      Service may be removed and accounts suspended.
                    </p>
                  </div>
                </div>
              </section>

              {/* 5. Third-Party Services */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  5. Third-Party Services
                </h2>
                <div className="grid md:grid-cols-4 gap-3 mb-10 ml-6">
                  <div className="relative rounded-lg border border-border/30 bg-muted/5 p-4">
                    <GlowingEffect
                      disabled={false}
                      spread={28}
                      proximity={48}
                      glow
                      borderWidth={1}
                    />
                    <div className="flex items-center gap-2 mb-1">
                      <Server className="w-4 h-4 text-foreground/80" />
                      <span className="text-sm font-semibold">Hetzner VPS</span>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Secure hosting for services and media storage.
                    </p>
                  </div>
                  <div className="relative rounded-lg border border-border/30 bg-muted/5 p-4">
                    <GlowingEffect
                      disabled={false}
                      spread={28}
                      proximity={48}
                      glow
                      borderWidth={1}
                    />
                    <div className="flex items-center gap-2 mb-1">
                      <KeyRound className="w-4 h-4 text-foreground/80" />
                      <span className="text-sm font-semibold">
                        Google OAuth
                      </span>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Sign-in only. We receive your email and profile if you
                      consent.
                    </p>
                  </div>
                  <div className="relative rounded-lg border border-border/30 bg-muted/5 p-4">
                    <GlowingEffect
                      disabled={false}
                      spread={28}
                      proximity={48}
                      glow
                      borderWidth={1}
                    />
                    <div className="flex items-center gap-2 mb-1">
                      <Database className="w-4 h-4 text-foreground/80" />
                      <span className="text-sm font-semibold">Supabase</span>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Stores account preferences and project metadata.
                    </p>
                  </div>
                  <div className="relative rounded-lg border border-border/30 bg-muted/5 p-4">
                    <GlowingEffect
                      disabled={false}
                      spread={28}
                      proximity={48}
                      glow
                      borderWidth={1}
                    />
                    <div className="flex items-center gap-2 mb-1">
                      <BarChart3 className="w-4 h-4 text-foreground/80" />
                      <span className="text-sm font-semibold">
                        Umami Analytics
                      </span>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Cookie-less, privacy-friendly usage analytics.
                    </p>
                  </div>
                </div>
              </section>

              {/* 6. Your Rights */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  6. Your Privacy Rights
                </h2>
                <div className="space-y-4 ml-8 text-sm text-muted-foreground">
                  <p>You have complete control over your data. You can:</p>
                  <ul className="ml-6 list-disc space-y-2">
                    <li>
                      <strong className="text-foreground">
                        Delete your account
                      </strong>
                      : remove your account and all associated data anytime.
                    </li>
                    <li>
                      <strong className="text-foreground">
                        Export your data
                      </strong>
                      : download your projects in a portable format.
                    </li>
                    <li>
                      <strong className="text-foreground">
                        Clear local storage
                      </strong>
                      : remove all locally saved projects.
                    </li>
                    <li>
                      <strong className="text-foreground">
                        Talk to a human
                      </strong>
                      : contact us anytime with privacy concerns.
                    </li>
                  </ul>
                </div>
              </section>

              {/* Open Source */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  7. Open-Source Transparency
                </h2>
                <div className="space-y-4 ml-11">
                  <p className="text-muted-foreground">
                    Kimu is open-source. Inspect how data flows, audit changes,
                    or contribute. We practice transparent engineering:
                  </p>
                  <ul className="list-disc ml-6 text-muted-foreground space-y-1">
                    <li>Public repo, issues, and pull requests</li>
                    <li>Changelogs and release notes</li>
                    <li>Incident reports for privacy/security events</li>
                  </ul>
                  <a
                    href="https://github.com/trykimu/videoeditor"
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex items-center gap-2 text-sm px-4 py-2 rounded-md border border-border/40 hover:bg-muted/10"
                  >
                    <Github className="w-4 h-4" />
                    <span className="font-medium">View source on GitHub</span>
                  </a>
                </div>
              </section>

              {/* Contact */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">8. Contact</h2>
                <div className="space-y-3 ml-11">
                  <p className="text-sm text-muted-foreground">
                    Have questions or requests? Create a ticket in our Discord
                    or email us.
                  </p>
                  <div className="flex flex-wrap gap-2">
                    <a
                      href="https://discord.com/invite/GSknuxubZK"
                      target="_blank"
                      rel="noreferrer"
                      className="text-xs px-3 py-1.5 rounded-md border border-border/30 hover:bg-muted/20"
                    >
                      Open Discord
                    </a>
                    <a
                      href="mailto:robinroy.work@gmail.com"
                      className="text-xs px-3 py-1.5 rounded-md border border-border/30 hover:bg-muted/20"
                    >
                      robinroy.work@gmail.com
                    </a>
                  </div>
                </div>
              </section>

              {/* Updates */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  9. Privacy Policy Changes
                </h2>

                <div className="space-y-4 ml-11">
                  <p className="text-sm text-muted-foreground">
                    We may update this Privacy Policy from time to time. When we
                    do, we will publish an updated version and effective date at
                    the top of this page, unless another type of notice is
                    legally required. Your continued use of Kimu after any
                    change in this Privacy Policy will constitute your
                    acceptance of such change.
                  </p>
                </div>
              </section>
            </div>
          </div>

          {/* Document Footer */}
          <div className="mt-16 pt-6 border-t border-border/20 flex items-center justify-between text-xs md:text-sm">
            <div>
              <span className="uppercase tracking-wider text-muted-foreground">
                Last updated
              </span>{" "}
              <span className="font-medium">30th August 2025</span>
            </div>
            <a
              href="/"
              className="inline-flex items-center gap-2 hover:underline font-medium"
              title="Back to Kimu"
            >
              <KimuLogo className="w-4 h-4" /> Return to Kimu
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}



================================================
FILE: app/routes/profile.tsx
================================================
import React from "react";
import { useAuth } from "~/hooks/useAuth";
import { Card } from "~/components/ui/card";
import { Button } from "~/components/ui/button";
import { useTheme } from "next-themes";
import { Sun, Moon, Monitor, HardDrive, FolderOpen, Calendar, ArrowLeft } from "lucide-react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "~/components/ui/select";
import { Progress } from "~/components/ui/progress";

export default function Profile() {
  const { user } = useAuth();
  const { theme, setTheme, systemTheme } = useTheme();
  const [usedBytes, setUsedBytes] = React.useState<number | null>(null);
  const [limitBytes, setLimitBytes] = React.useState<number>(2 * 1024 * 1024 * 1024);
  const [projectCount, setProjectCount] = React.useState<number | null>(null);
  const [memberSince, setMemberSince] = React.useState<string | null>(null);

  React.useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const res = await fetch("/api/storage", { credentials: "include" });
        if (!res.ok) return;
        const j = await res.json();
        if (!cancelled) {
          const u = Number(j?.usedBytes || 0);
          const l = Number(j?.limitBytes || limitBytes);
          setUsedBytes(Number.isFinite(u) ? u : 0);
          setLimitBytes(Number.isFinite(l) ? l : 2 * 1024 * 1024 * 1024);
        }
      } catch (error) {
        console.error('Failed to fetch storage info:', error);
      }
    })();
    (async () => {
      try {
        const res = await fetch("/api/auth/session", { credentials: "include" });
        if (!res.ok) return;
        const j = await res.json();
        const created = j?.user?.createdAt || j?.user?.created_at || j?.user?.created_at_ms || null;
        if (!cancelled && created) setMemberSince(String(created));
      } catch (error) {
        console.error('Failed to fetch user session:', error);
      }
    })();
    (async () => {
      try {
        const res = await fetch("/api/projects", { credentials: "include" });
        if (!res.ok) return;
        const j = await res.json();
        if (!cancelled) setProjectCount(Array.isArray(j?.projects) ? j.projects.length : 0);
      } catch (error) {
        console.error('Failed to fetch projects:', error);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [limitBytes]);

  const formatBytes = (bytes: number): string => {
    if (!Number.isFinite(bytes) || bytes <= 0) return "0 B";
    const units = ["B", "KB", "MB", "GB", "TB"] as const;
    const i = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
    const val = bytes / Math.pow(1024, i);
    return `${val >= 100 ? Math.round(val) : val.toFixed(1)} ${units[i]}`;
  };

  return (
    <div className="min-h-screen w-full bg-background pt-16 sm:pt-20">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 py-6">
        <div className="mb-4">
          <button
            className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
            onClick={() => {
              if (window.history.length > 1) window.history.back();
              else window.location.href = "/projects";
            }}>
            <ArrowLeft className="h-4 w-4" /> Back
          </button>
        </div>
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
          <div className="flex items-center gap-4">
            <img
              src={user?.image || "/kimu.svg"}
              alt="avatar"
              className="h-16 w-16 rounded-full border border-border object-cover"
            />
            <div>
              <h1 className="text-xl font-semibold">{user?.name || "User"}</h1>
              <div className="text-sm text-muted-foreground">{user?.email}</div>
            </div>
          </div>
          <div className="flex items-center gap-2 sm:justify-end">
            <div className="text-sm text-muted-foreground">Theme</div>
            <Select
              value={theme === "light" || theme === "dark" ? theme : "system"}
              onValueChange={(v: 'light' | 'dark' | 'system') => setTheme(v)}>
              <SelectTrigger size="sm" className="w-40">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="light">
                  <span className="inline-flex items-center gap-2">
                    <Sun className="size-4" /> Light
                  </span>
                </SelectItem>
                <SelectItem value="dark">
                  <span className="inline-flex items-center gap-2">
                    <Moon className="size-4" /> Dark
                  </span>
                </SelectItem>
                <SelectItem value="system">
                  <span className="inline-flex items-center gap-2">
                    <Monitor className="size-4" /> System
                  </span>
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="p-4">
            <div className="text-sm text-muted-foreground mb-2 inline-flex items-center gap-2">
              <HardDrive className="h-4 w-4" /> Total storage used
            </div>
            <div className="text-2xl font-semibold">
              {usedBytes === null ? "—" : `${formatBytes(usedBytes)} / ${formatBytes(limitBytes)}`}
            </div>
            <div className="mt-3">
              <Progress
                // @ts-ignore radix value type
                value={
                  usedBytes !== null && limitBytes > 0 ? Math.min(100, Math.max(0, (usedBytes / limitBytes) * 100)) : 0
                }
              />
            </div>
          </Card>
          <Card className="p-4">
            <div className="text-sm text-muted-foreground inline-flex items-center gap-2">
              <FolderOpen className="h-4 w-4" /> Projects
            </div>
            <div className="text-2xl font-semibold mt-1">{projectCount === null ? "—" : projectCount}</div>
          </Card>
          <Card className="p-4">
            <div className="text-sm text-muted-foreground inline-flex items-center gap-2">
              <Calendar className="h-4 w-4" /> Member since
            </div>
            <div className="text-2xl font-semibold mt-1">
              {memberSince ? new Date(memberSince).toLocaleDateString() : "—"}
            </div>
          </Card>
        </div>

        <div className="mt-6">
          <Button variant="outline">Manage Subscription</Button>
        </div>
      </div>
    </div>
  );
}



================================================
FILE: app/routes/project.$id.tsx
================================================
import { useParams, useNavigate, useLoaderData, type LoaderFunctionArgs } from "react-router";
import React, { useEffect } from "react";
import TimelineEditor from "./home";
import { auth } from "~/lib/auth.server";
import { loadTimeline } from "~/lib/timeline.store";
import type { TimelineState } from "~/components/timeline/types";

export async function loader({ request, params }: LoaderFunctionArgs) {
  // SSR gate: verify auth
  try {
    const session = await auth.api?.getSession?.({ headers: request.headers });
    const uid: string | undefined = session?.user?.id || session?.session?.userId;
    if (!uid)
      return new Response(null, {
        status: 302,
        headers: { Location: "/login" },
      });
  } catch {
    return new Response(null, { status: 302, headers: { Location: "/login" } });
  }
  // Optionally prefetch timeline to hydrate client faster
  const id = params.id as string;
  const timeline = await loadTimeline(id);
  return { timeline };
}

export default function ProjectEditorRoute() {
  const params = useParams();
  const navigate = useNavigate();
  const id = params.id as string;
  const data = useLoaderData() as { timeline?: TimelineState };

  useEffect(() => {
    // Lightweight guard: verify project ownership before showing editor
    (async () => {
      const res = await fetch(`/api/projects/${encodeURIComponent(id)}`, {
        credentials: "include",
      });
      if (!res.ok) navigate("/projects");
    })();
  }, [id, navigate]);

  // Pass through existing editor; it manages state internally. We injected loader for prefetch.
  return <TimelineEditor />;
}



================================================
FILE: app/routes/projects.tsx
================================================
import React, { useEffect, useState, useMemo } from "react";
import { AnimatePresence, motion } from "motion/react";
import { Button } from "~/components/ui/button";
import { Card } from "~/components/ui/card";
import { useNavigate, type LoaderFunctionArgs } from "react-router";
import { useAuth } from "~/hooks/useAuth";
import { ProfileMenu } from "~/components/ui/ProfileMenu";
import {
  Plus,
  ChevronDown,
  ArrowUpDown,
  CalendarClock,
  ArrowDownAZ,
  ArrowUpAZ,
  Check,
  Trash2,
  MoreVertical,
  Edit3,
  Wand2,
  Clapperboard,
  ChevronRight,
  Pencil,
} from "lucide-react";
import { KimuLogo } from "~/components/ui/KimuLogo";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "~/components/ui/dropdown-menu";
import { Modal } from "~/components/ui/modal";
import { Drawer, DrawerContent, DrawerFooter, DrawerHeader, DrawerTitle } from "~/components/ui/drawer";
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogFooter as ADFooter,
  AlertDialogAction,
  AlertDialogCancel,
} from "~/components/ui/alert-dialog";
import { Input } from "~/components/ui/input";
import { auth } from "~/lib/auth.server";
import { cn } from "~/lib/utils";

type Project = { id: string; name: string; created_at: string };

const ProjectHoverEffect = ({
  projects,
  onProjectClick,
  onRename,
  onDelete,
  formatDate,
  formatTime,
}: {
  projects: Project[];
  onProjectClick: (projectId: string) => void;
  onRename: (projectId: string, currentName: string) => void;
  onDelete: (projectId: string) => void;
  formatDate: (dateString: string) => string;
  formatTime: (dateString: string) => string;
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <div className={cn("grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4")}>
      {projects.map((project, idx) => (
        <div
          key={project.id}
          className="relative group block p-2 h-full w-full"
          onMouseEnter={() => setHoveredIndex(idx)}
          onMouseLeave={() => setHoveredIndex(null)}>
          <AnimatePresence>
            {hoveredIndex === idx && (
              <motion.span
                className="pointer-events-none absolute inset-1 h-[calc(100%-8px)] w-[calc(100%-8px)] bg-neutral-900/40 dark:bg-neutral-800/70 rounded-2xl border border-neutral-700/60"
                layoutId="hoverBackground"
                initial={{ opacity: 0 }}
                animate={{
                  opacity: 1,
                  transition: { duration: 0.15 },
                }}
                exit={{
                  opacity: 0,
                  transition: { duration: 0.15, delay: 0.2 },
                }}
              />
            )}
          </AnimatePresence>
          <ProjectCard
            project={project}
            onProjectClick={onProjectClick}
            onRename={onRename}
            onDelete={onDelete}
            formatDate={formatDate}
            formatTime={formatTime}
          />
        </div>
      ))}
    </div>
  );
};

const ProjectCard = ({
  project,
  onProjectClick,
  onRename,
  onDelete,
  formatDate,
  formatTime,
}: {
  project: Project;
  onProjectClick: (projectId: string) => void;
  onRename: (projectId: string, currentName: string) => void;
  onDelete: (projectId: string) => void;
  formatDate: (dateString: string) => string;
  formatTime: (dateString: string) => string;
}) => {
  return (
    <Card
      className={cn(
        "group h-36 border-border/20 bg-card/50 hover:bg-card hover:border-border/30 backdrop-blur-sm transition-all duration-300 cursor-pointer relative overflow-hidden z-20",
      )}
      onClick={() => onProjectClick(project.id)}>
      <div className="p-5 h-full flex flex-col relative">
        {/* Project name */}
        <div className="flex-1 relative z-10">
          <h3
            className="text-lg font-semibold text-foreground leading-tight"
            style={{
              display: "-webkit-box",
              WebkitLineClamp: 2,
              WebkitBoxOrient: "vertical",
              overflow: "hidden",
            }}>
            {project.name}
          </h3>
        </div>

        {/* Date and time - positioned at very bottom */}
        <div className="space-y-0.5 relative z-10 mt-auto mb-1">
          <p className="text-xs text-muted-foreground font-medium">{formatDate(project.created_at)}</p>
          <p className="text-[10px] text-muted-foreground/70">{formatTime(project.created_at)}</p>
        </div>

        {/* Actions: always visible on mobile, show on hover for desktop */}
        <div className="absolute bottom-0.5 right-0.5 transition-opacity duration-300 z-20 opacity-100 sm:opacity-0 sm:group-hover:opacity-100">
          <button
            className="p-1.5 text-muted-foreground hover:text-foreground transition-colors duration-200"
            onClick={(e) => {
              e.stopPropagation();
              onRename(project.id, project.name);
            }}
            aria-label="Open project actions">
            <MoreVertical className="h-4 w-4" />
          </button>
        </div>
      </div>
    </Card>
  );
};

export async function loader({ request }: { request: Request }) {
  try {
    // Prefer Better Auth runtime API to avoid SSR fetch cookie issues
    // @ts-ignore
    const session = await auth.api?.getSession?.({ headers: request.headers });
    const uid: string | undefined = session?.user?.id || session?.session?.userId;
    if (!uid)
      return new Response(null, {
        status: 302,
        headers: { Location: "/login" },
      });
  } catch {
    return new Response(null, { status: 302, headers: { Location: "/login" } });
  }
  return null;
}

export default function Projects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [sortBy, setSortBy] = useState<"created_desc" | "created_asc" | "name_asc" | "name_desc">("created_desc");
  const navigate = useNavigate();
  const { user, signOut } = useAuth();
  const [starCount, setStarCount] = useState<number | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newProjectName, setNewProjectName] = useState("");
  const [renameProjectId, setRenameProjectId] = useState<string | null>(null);
  const [renameValue, setRenameValue] = useState("");
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [drawerDirection, setDrawerDirection] = useState<"right" | "bottom">("right");
  const [confirmDeleteOpen, setConfirmDeleteOpen] = useState(false);

  useEffect(() => {
    const update = () => {
      try {
        const isMobile = window.matchMedia("(max-width: 639px)").matches;
        setDrawerDirection(isMobile ? "bottom" : "right");
      } catch {
        console.error("Failed to update drawer direction");
      }
    };
    update();
    window.addEventListener("resize", update);
    return () => window.removeEventListener("resize", update);
  }, []);

  // Format date as "23 Aug 25"
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const day = date.getDate();
    const month = date.toLocaleDateString("en-US", { month: "short" });
    const year = date.getFullYear().toString().slice(-2);
    return `${day} ${month} ${year}`;
  };

  // Format time as "2:30 PM"
  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
  };
  useEffect(() => {
    if (!user) return; // loader already gates; avoid client redirect loops
  }, [user]);

  useEffect(() => {
    const fetchStars = async () => {
      try {
        const res = await fetch("https://api.github.com/repos/trykimu/videoeditor");
        if (res.ok) {
          const data = await res.json();
          setStarCount(typeof data.stargazers_count === "number" ? data.stargazers_count : null);
        }
      } catch {
        console.error("Failed to fetch star count");
        setStarCount(null);
      }
    };
    fetchStars();
  }, []);

  useEffect(() => {
    const load = async () => {
      try {
        const res = await fetch("/api/projects", { credentials: "include" });
        if (res.ok) {
          const json = await res.json();
          setProjects(json.projects || []);
        }
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const create = async (projectName?: string) => {
    const name = (projectName || newProjectName || "Untitled Project").trim().slice(0, 120);
    setCreating(true);
    try {
      const res = await fetch("/api/projects", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name }),
      });
      if (res.ok || res.status === 201) {
        const { project } = await res.json();
        navigate(`/project/${project.id}`);
      }
    } finally {
      setCreating(false);
    }
  };

  const sortedProjects = useMemo(() => {
    const arr = [...projects];
    switch (sortBy) {
      case "created_asc":
        return arr.sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
      case "name_asc":
        return arr.sort((a, b) => a.name.localeCompare(b.name));
      case "name_desc":
        return arr.sort((a, b) => b.name.localeCompare(a.name));
      case "created_desc":
      default:
        return arr.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
    }
  }, [projects, sortBy]);

  return (
    <div className="min-h-screen w-full bg-background relative overflow-hidden">
      {/* Subtle dotted grid only */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 opacity-[0.06] bg-[radial-gradient(circle_at_center,rgba(255,255,255,0.6)_1px,transparent_1px)] [background-size:16px_16px]"
      />
      <header className="h-10 sm:h-12 border-b border-border/50 bg-background/80 backdrop-blur supports-[backdrop-filter]:bg-background/60 flex items-center justify-between px-3 sm:px-6">
        <div className="flex items-center gap-2 min-w-0">
          <KimuLogo className="h-5 w-5 shrink-0" />
          <span className="text-sm font-medium truncate">Kimu Studio</span>
        </div>
        <div className="flex items-center gap-2">
          {user && (
            <ProfileMenu
              user={{ name: user.name, email: user.email, image: user.image }}
              starCount={starCount}
              onSignOut={signOut}
            />
          )}
        </div>
      </header>
      <main className="max-w-7xl mx-auto px-4 sm:px-6 py-6 sm:py-8">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-6 sm:mb-10">
          <div className="flex items-center gap-2">
            <h1 className="text-xl sm:text-2xl font-bold">Your Projects</h1>
            <span className="text-[11px] text-muted-foreground border border-border/30 rounded-full px-2 py-0.5">
              {projects.length}
            </span>
          </div>
          <div className="flex items-center gap-2 self-start sm:self-auto">
            <Button
              size="sm"
              className="h-8"
              onClick={() => {
                setNewProjectName("");
                setShowCreateModal(true);
              }}
              disabled={creating}>
              <Plus className="h-3.5 w-3.5 mr-1" />
              New Project
            </Button>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button size="sm" variant="outline" className="h-8">
                  <ArrowUpDown className="h-3.5 w-3.5 mr-1" />
                  Sort
                  <ChevronDown className="h-3.5 w-3.5 ml-1" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuLabel className="text-[11px]">Sort projects</DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  onClick={() => setSortBy("created_desc")}
                  className={`text-xs flex items-center gap-2 ${sortBy === "created_desc" ? "text-primary" : ""}`}>
                  {sortBy === "created_desc" ? <Check className="h-3 w-3" /> : <CalendarClock className="h-3 w-3" />}
                  Date (newest first)
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => setSortBy("created_asc")}
                  className={`text-xs flex items-center gap-2 ${sortBy === "created_asc" ? "text-primary" : ""}`}>
                  {sortBy === "created_asc" ? <Check className="h-3 w-3" /> : <CalendarClock className="h-3 w-3" />}
                  Date (oldest first)
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => setSortBy("name_asc")}
                  className={`text-xs flex items-center gap-2 ${sortBy === "name_asc" ? "text-primary" : ""}`}>
                  {sortBy === "name_asc" ? <Check className="h-3 w-3" /> : <ArrowUpAZ className="h-3 w-3" />}
                  Name (A–Z)
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => setSortBy("name_desc")}
                  className={`text-xs flex items-center gap-2 ${sortBy === "name_desc" ? "text-primary" : ""}`}>
                  {sortBy === "name_desc" ? <Check className="h-3 w-3" /> : <ArrowDownAZ className="h-3 w-3" />}
                  Name (Z–A)
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {Array.from({ length: 10 }, (_, i) => (
              <div key={`loading-${i}`} className="p-2">
                <Card className="h-36 animate-pulse bg-muted/15 border-border/20" />
              </div>
            ))}
          </div>
        ) : projects.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-center">
            <div className="w-20 h-20 rounded-2xl bg-muted/30 flex items-center justify-center mb-6 border border-border/20">
              <Clapperboard className="h-9 w-9 text-muted-foreground/40" />
            </div>
            <h3 className="text-xl font-medium text-muted-foreground/80 mb-3">Nothing here yet...</h3>
            <div className="max-w-md space-y-2">
              <p className="text-sm text-muted-foreground/60">Your creative journey starts with a single click!</p>
              <p className="text-sm text-muted-foreground/60">
                Hit that shiny <span className="font-medium text-muted-foreground/80">"New Project"</span> button up
                there to get started.
              </p>
            </div>
          </div>
        ) : (
          <ProjectHoverEffect
            projects={sortedProjects}
            onProjectClick={(projectId) => navigate(`/project/${projectId}`)}
            onRename={(projectId, currentName) => {
              setRenameProjectId(projectId);
              setRenameValue(currentName);
              setDrawerOpen(true);
            }}
            onDelete={async (projectId) => {
              const res = await fetch(`/api/projects/${encodeURIComponent(projectId)}`, {
                method: "DELETE",
                credentials: "include",
              });
              if (res.ok) setProjects((prev) => prev.filter((x) => x.id !== projectId));
            }}
            formatDate={formatDate}
            formatTime={formatTime}
          />
        )}
      </main>
      {/* Create Project Modal */}
      <Modal open={showCreateModal} onClose={() => setShowCreateModal(false)} title="Create new project">
        <div className="space-y-3">
          <Input
            placeholder="Project name"
            value={newProjectName}
            onChange={(e) => setNewProjectName(e.target.value)}
          />
          <div className="flex justify-end gap-2">
            <Button variant="ghost" onClick={() => setShowCreateModal(false)}>
              Cancel
            </Button>
            <Button
              onClick={async () => {
                await create();
              }}
              disabled={creating || !newProjectName.trim()}>
              Create
            </Button>
          </div>
        </div>
      </Modal>
      {/* Edit Drawer */}
      <Drawer open={drawerOpen} onOpenChange={setDrawerOpen} direction={drawerDirection}>
        <DrawerContent>
          <div className="p-4 sm:p-6 h-full flex flex-col gap-4">
            <DrawerHeader>
              <DrawerTitle className="text-base">Edit project</DrawerTitle>
            </DrawerHeader>
            <div className="text-xs text-muted-foreground">
              ID: <span className="font-mono">{renameProjectId}</span>
            </div>
            <div>
              <div className="text-xs text-muted-foreground mb-1">Project name</div>
              <Input value={renameValue} onChange={(e) => setRenameValue(e.target.value)} />
            </div>
            <DrawerFooter className="mt-auto">
              <div className="flex justify-end gap-2">
                <Button variant="ghost" onClick={() => setDrawerOpen(false)}>
                  Cancel
                </Button>
                <Button
                  disabled={
                    !renameProjectId ||
                    renameValue.trim() === (projects.find((p) => p.id === renameProjectId)?.name || "")
                  }
                  onClick={async () => {
                    const id = renameProjectId!;
                    const newName = renameValue.trim();
                    if (!newName) return;
                    const res = await fetch(`/api/projects/${encodeURIComponent(id)}`, {
                      method: "PATCH",
                      credentials: "include",
                      headers: { "Content-Type": "application/json" },
                      body: JSON.stringify({ name: newName }),
                    });
                    if (res.ok) setProjects((prev) => prev.map((x) => (x.id === id ? { ...x, name: newName } : x)));
                    setDrawerOpen(false);
                  }}>
                  Save
                </Button>
              </div>
              <button
                className="text-destructive flex items-center gap-2 text-sm"
                onClick={() => setConfirmDeleteOpen(true)}>
                <Trash2 className="h-4 w-4" /> Delete project
              </button>
            </DrawerFooter>
          </div>
        </DrawerContent>
      </Drawer>

      {/* Confirm delete */}
      <AlertDialog open={confirmDeleteOpen} onOpenChange={setConfirmDeleteOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete project?</AlertDialogTitle>
            <AlertDialogDescription>This action cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <ADFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              onClick={async () => {
                const id = renameProjectId!;
                if (!id) return;
                const res = await fetch(`/api/projects/${encodeURIComponent(id)}`, {
                  method: "DELETE",
                  credentials: "include",
                });
                if (res.ok) setProjects((prev) => prev.filter((x) => x.id !== id));
                setConfirmDeleteOpen(false);
                setDrawerOpen(false);
              }}>
              Delete
            </AlertDialogAction>
          </ADFooter>
        </AlertDialogContent>
      </AlertDialog>
      {/* Playful Kimu mascot: gentle float in the corner; spin with chime on click */}
      <style>{`@keyframes kimu-float { 0%{transform:translateY(0)} 50%{transform:translateY(-6px)} 100%{transform:translateY(0)} }
      @keyframes kimu-spin { 0%{transform:rotate(0)} 100%{transform:rotate(360deg)} }`}</style>
      <div
        className="fixed right-6 bottom-6 z-10 select-none"
        onClick={() => {
          const el = document.getElementById("kimu-mascot");
          if (!el) return;
          // spin
          el.style.animation = "kimu-spin 0.9s linear";
          setTimeout(() => {
            el.style.animation = "kimu-float 3.5s ease-in-out infinite";
          }, 950);
          // chime (like landing)
          try {
            const AudioCtx: typeof AudioContext | undefined =
              (
                window as {
                  AudioContext?: typeof AudioContext;
                  webkitAudioContext?: typeof AudioContext;
                }
              ).AudioContext ||
              (
                window as {
                  AudioContext?: typeof AudioContext;
                  webkitAudioContext?: typeof AudioContext;
                }
              ).webkitAudioContext;
            if (!AudioCtx) throw new Error("AudioContext not supported");
            const ctx = new AudioCtx();
            const make = (freq: number, delay: number, dur: number) => {
              const osc = ctx.createOscillator();
              const gain = ctx.createGain();
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.frequency.setValueAtTime(freq, ctx.currentTime + delay);
              osc.type = "sine";
              gain.gain.setValueAtTime(0.12, ctx.currentTime + delay);
              gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + dur);
              osc.start(ctx.currentTime + delay);
              osc.stop(ctx.currentTime + delay + dur);
            };
            make(659.25, 0, 0.25);
            make(783.99, 0.08, 0.22);
            make(987.77, 0.16, 0.18);
          } catch {
            console.error("Kimu mascot chime failed");
          }
        }}>
        <KimuLogo
          id="kimu-mascot"
          opacity={0.2}
          className="h-8 w-8 text-foreground cursor-pointer"
          style={{ animation: "kimu-float 3.5s ease-in-out infinite" }}
          animated
        />
      </div>
    </div>
  );
}



================================================
FILE: app/routes/roadmap.tsx
================================================
import * as React from "react";
import { useState } from "react";
import { motion } from "framer-motion";
import { KimuLogo } from "../components/ui/KimuLogo";
import { Link } from "react-router";
import {
  Github,
  Twitter,
  Play,
  Pause,
  ArrowLeft,
  Zap,
  Wand2,
  Sparkles,
  Users,
  Smartphone,
} from "lucide-react";

// Timeline items for different tracks
interface TimelineItem {
  id: string;
  title: string;
  status: "completed" | "in-progress" | "planned";
  quarter: string;
  progress?: number;
  icon: React.ReactNode;
  color: string;
  startTime: number;
  duration: number;
}

// Track 1: Core Features
const coreFeatures: TimelineItem[] = [
  {
    id: "editor",
    title: "Core Editor",
    status: "completed",
    quarter: "Q4 2024",
    progress: 100,
    icon: <Zap className="w-3 h-3" />,
    color: "bg-green-500",
    startTime: 0,
    duration: 3,
  },
  {
    id: "ai",
    title: "AI Assistant",
    status: "in-progress",
    quarter: "Q1 2025",
    progress: 75,
    icon: <Wand2 className="w-3 h-3" />,
    color: "bg-blue-500",
    startTime: 2,
    duration: 4,
  },
];

// Track 2: Advanced Features
const advancedFeatures: TimelineItem[] = [
  {
    id: "effects",
    title: "Effects & Filters",
    status: "in-progress",
    quarter: "Q1 2025",
    progress: 45,
    icon: <Sparkles className="w-3 h-3" />,
    color: "bg-purple-500",
    startTime: 3,
    duration: 3,
  },
  {
    id: "collaboration",
    title: "Collaboration",
    status: "planned",
    quarter: "Q2 2025",
    progress: 0,
    icon: <Users className="w-3 h-3" />,
    color: "bg-orange-500",
    startTime: 5,
    duration: 2,
  },
];

// Track 3: Platform Expansion
const platformFeatures: TimelineItem[] = [
  {
    id: "mobile",
    title: "Mobile App",
    status: "planned",
    quarter: "Q2 2025",
    progress: 0,
    icon: <Smartphone className="w-3 h-3" />,
    color: "bg-pink-500",
    startTime: 6,
    duration: 3,
  },
];

const maxTime = 9; // Total timeline duration

// Timeline Track Component
const TimelineTrack: React.FC<{
  title: string;
  items: TimelineItem[];
  color: string;
  delay: number;
}> = ({ title, items, color, delay }) => {
  // Calculate current implementation progress
  const calculateProgress = React.useCallback(() => {
    let totalProgress = 0;
    let totalWeight = 0;

    items.forEach((item) => {
      if (item.status === "completed") {
        totalProgress += item.duration;
      } else if (item.status === "in-progress" && item.progress) {
        totalProgress += (item.duration * item.progress) / 100;
      }
      totalWeight += item.duration;
    });

    return totalWeight > 0 ? (totalProgress / totalWeight) * maxTime : 0;
  }, [items]);

  const [currentTime, setCurrentTime] = useState(calculateProgress());
  const [isPlaying, setIsPlaying] = useState(false);

  React.useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isPlaying) {
      interval = setInterval(() => {
        setCurrentTime((prev) => (prev >= maxTime ? 0 : prev + 0.1));
      }, 100);
    } else {
      setCurrentTime(calculateProgress());
    }
    return () => clearInterval(interval);
  }, [calculateProgress, isPlaying]);

  return (
    <motion.div
      className="space-y-3"
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.6, delay }}
    >
      <div className="flex items-center gap-3">
        <div className={`w-3 h-3 ${color} rounded-full`} />
        <span className="text-sm font-medium text-foreground">{title}</span>
        <button
          onClick={() => setIsPlaying(!isPlaying)}
          className="ml-auto w-6 h-6 bg-muted/20 rounded-full flex items-center justify-center hover:bg-muted/30 transition-colors"
        >
          {isPlaying ? (
            <Pause className="w-3 h-3 text-foreground" />
          ) : (
            <Play className="w-3 h-3 text-foreground" />
          )}
        </button>
      </div>

      <div className="relative h-12 bg-muted/10 rounded-lg border border-border/20">
        {/* Playhead */}
        <motion.div
          className="absolute top-0 bottom-0 w-0.5 bg-red-500 z-20"
          animate={{ left: `${(currentTime / maxTime) * 100}%` }}
          transition={{ duration: 0.1 }}
        >
          <div className="absolute -top-1 -left-1 w-2 h-2 bg-red-500 rounded-full" />
        </motion.div>

        {items.map((item, index) => {
          const leftPosition = (item.startTime / maxTime) * 100;
          const width = (item.duration / maxTime) * 100;

          return (
            <motion.div
              key={item.id}
              className={`absolute top-1 bottom-1 ${item.color}/80 rounded border-l-2 border-white/30 cursor-pointer group overflow-hidden`}
              style={{
                left: `${leftPosition}%`,
                width: `${width}%`,
              }}
              initial={{ scaleX: 0 }}
              whileInView={{ scaleX: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: delay + index * 0.1 }}
              whileHover={{ scale: 1.02, zIndex: 10 }}
            >
              <div className="h-full flex items-center px-2 text-white">
                <div className="flex items-center gap-1 min-w-0">
                  {item.icon}
                  <span className="text-xs font-medium truncate">
                    {item.title}
                  </span>
                </div>
                {item.status === "in-progress" && item.progress && (
                  <div
                    className="absolute inset-0 bg-white/20 rounded"
                    style={{ width: `${item.progress}%` }}
                  />
                )}
              </div>

              {/* Tooltip */}
              <div className="absolute -top-16 left-1/2 -translate-x-1/2 bg-black text-white p-3 rounded-lg text-sm opacity-0 group-hover:opacity-100 transition-opacity z-50 min-w-40 border border-white/20 shadow-lg">
                <div className="font-medium text-white">{item.title}</div>
                <div className="flex items-center justify-between mt-2">
                  <span
                    className={`px-2 py-1 rounded text-xs font-medium ${
                      item.status === "completed"
                        ? "bg-green-500/30 text-green-300"
                        : item.status === "in-progress"
                        ? "bg-blue-500/30 text-blue-300"
                        : "bg-gray-500/30 text-gray-300"
                    }`}
                  >
                    {item.status === "completed"
                      ? "Done"
                      : item.status === "in-progress"
                      ? `${item.progress}%`
                      : "Planned"}
                  </span>
                  <span className="text-white/70 text-xs">{item.quarter}</span>
                </div>
              </div>
            </motion.div>
          );
        })}
      </div>
    </motion.div>
  );
};

export default function Roadmap() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Header */}
      <header className="border-b border-border/10 sticky top-0 z-50 bg-background/80 backdrop-blur-sm">
        <div className="max-w-4xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <Link
              to="/"
              className="flex items-center gap-3 hover:opacity-80 transition-opacity"
            >
              <KimuLogo className="w-6 h-6 text-foreground" />
              <span className="font-medium text-foreground">Roadmap</span>
            </Link>

            <div className="flex items-center gap-6">
              <a
                href="https://github.com/robinroy03/videoeditor"
                target="_blank"
                rel="noopener noreferrer"
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                <Github className="w-5 h-5" />
              </a>
              <a
                href="https://twitter.com/trykimu"
                target="_blank"
                rel="noopener noreferrer"
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                <Twitter className="w-5 h-5" />
              </a>
              <a
                href="https://discord.gg/24Mt5DGcbx"
                target="_blank"
                rel="noopener noreferrer"
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                <svg
                  className="w-5 h-5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M8 12a1 1 0 1 0 2 0a1 1 0 0 0 -2 0" />
                  <path d="M14 12a1 1 0 1 0 2 0a1 1 0 0 0 -2 0" />
                  <path d="M15.5 17c0 1 1.5 3 2 3c1.5 0 2.833 -1.667 3.5 -3c0.667 -1.667 0.5 -5.833 -1.5 -11.5c-1.457 -1.015 -3 -1.34 -4.5 -1.5l-0.972 1.923a11.913 11.913 0 0 0 -4.053 0l-0.975 -1.923c-1.5 0.16 -3.043 0.485 -4.5 1.5c-2 5.667 -2.167 9.833 -1.5 11.5c0.667 1.333 2 3 3.5 3c0.5 0 2 -2 2 -3" />
                  <path d="M7 16.5c3.5 1 6.5 1 10 0" />
                </svg>
              </a>
              <Link
                to="/"
                className="text-sm text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
              >
                <ArrowLeft className="w-4 h-4" />
                Back
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Main Timeline Content */}
      <div className="max-w-4xl mx-auto px-6 py-16">
        {/* Roadmap Header */}
        <div className="text-center mb-12">
          <h1 className="text-3xl md:text-4xl font-bold text-foreground mb-4">
            Roadmap
          </h1>
          <h2 className="text-lg text-muted-foreground mb-2">
            Development Timeline
          </h2>
          <p className="text-sm text-muted-foreground max-w-2xl mx-auto">
            Track our progress as we build the future of video editing. Each
            timeline shows different feature tracks with projected
            implementation schedules.
          </p>
        </div>

        <div className="space-y-8">
          <TimelineTrack
            title="Core Features"
            items={coreFeatures}
            color="bg-blue-500"
            delay={0}
          />
          <TimelineTrack
            title="Advanced Features"
            items={advancedFeatures}
            color="bg-purple-500"
            delay={0.2}
          />
          <TimelineTrack
            title="Platform Expansion"
            items={platformFeatures}
            color="bg-pink-500"
            delay={0.4}
          />
        </div>
      </div>
    </div>
  );
}



================================================
FILE: app/routes/terms.tsx
================================================
import * as React from "react";
import { Calendar } from "lucide-react";
import { KimuLogo } from "~/components/ui/KimuLogo";
import { GlowingEffect } from "~/components/ui/glowing-effect";

export default function Terms() {
  const lastUpdated = `30th August 2025`

  return (
    <div className="min-h-screen bg-background text-foreground pt-20">
      {/* Hero / Masthead */}
      <div className="relative overflow-hidden">
        <div aria-hidden className="pointer-events-none absolute inset-0 -z-10">
          <div className="absolute -top-32 right-1/4 w-[40rem] h-[40rem] rounded-full bg-[radial-gradient(circle,rgba(99,102,241,0.22),transparent_60%)] blur-3xl" />
          <div className="absolute -bottom-32 left-1/4 w-[40rem] h-[40rem] rounded-full bg-[radial-gradient(circle,rgba(16,185,129,0.18),transparent_60%)] blur-3xl" />
        </div>
        <div className="max-w-5xl mx-auto px-6 pt-10 pb-6 text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-border/30 text-xs text-muted-foreground mb-4">
            Terms of Service
          </div>
          <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight">
            Kimu Terms of Service
          </h1>
          <div className="mt-4 flex items-center justify-center gap-4 text-xs text-muted-foreground">
            <span className="inline-flex items-center gap-1">
              <Calendar className="w-4 h-4" /> Effective {lastUpdated}
            </span>
            <span className="w-1 h-1 rounded-full bg-current/60" />
            <span>Version 1.0</span>
          </div>
        </div>
      </div>

      {/* Document Container */}
      <div className="max-w-5xl mx-auto px-6 pb-20">
        <div className="relative rounded-2xl border border-border/30 bg-background/80 shadow-2xl p-6 md:p-10">
          <GlowingEffect
            disabled={false}
            spread={44}
            proximity={72}
            glow
            borderWidth={1}
            hoverBorderWidth={3}
          />

          {/* Document Header Preamble */}
          <div className="text-left mb-8 pb-6 border-b border-border/20">
            <div className="flex items-center justify-center gap-3 mb-3">
              <KimuLogo className="w-6 h-6 text-foreground" />
              <span className="text-sm font-semibold tracking-tight">Kimu</span>
            </div>
            <div className="mx-auto max-w-3xl rounded-lg border border-border/30 bg-muted/5 px-4 py-3 text-xs font-mono text-muted-foreground">
              These Terms of Service ("Terms") govern your access to and use of
              Kimu — a web‑based video editor with AI features and optional
              cloud storage and collaboration. By creating an account or using
              Kimu, you agree to these Terms.
            </div>
          </div>

          {/* Document Content */}
          <div className="prose prose-slate dark:prose-invert max-w-none">
            <div className="space-y-8 text-foreground leading-relaxed">
              {/* 1. Acceptance */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  1. Acceptance of Terms
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    By accessing or using Kimu, you accept these Terms and our
                    Privacy Policy. If you don’t agree, do not use Kimu.
                  </p>
                  <p>
                    Where required by law, additional terms may apply (e.g.,
                    consumer rights). If there is a conflict, the more
                    protective mandatory terms prevail.
                  </p>
                </div>
              </section>

              {/* 2. Eligibility & Accounts */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  2. Eligibility & Accounts
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <ul className="list-disc ml-6 space-y-1">
                    <li>
                      You must be at least 13 years old (or the minimum age in
                      your country) to use Kimu.
                    </li>
                    <li>
                      You are responsible for your account credentials and for
                      all activity under your account.
                    </li>
                    <li>
                      We may require identity checks for abuse prevention,
                      fraud, or legal compliance.
                    </li>
                  </ul>
                </div>
              </section>

              {/* 3. Service Description */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  3. Service Description
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    Kimu provides a browser‑based non‑linear video editor,
                    AI‑assisted features (e.g., cuts, captions, titles, effects,
                    transitions), and optional cloud projects for storage and
                    collaboration. Features may vary by plan and region, and may
                    evolve over time.
                  </p>
                  <p>
                    AI features may rely on third‑party model providers. Outputs
                    can be inaccurate or unsafe if misused. You are responsible
                    for reviewing AI outputs before use or publication.
                  </p>
                </div>
              </section>

              {/* 4. Your Content & Ownership */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  4. Your Content & Ownership
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    You retain ownership of the videos, audio, images, text, and
                    other content you upload or create in Kimu ("User Content").
                  </p>
                  <p>
                    To operate Kimu, you grant us a limited, worldwide,
                    non‑exclusive license to host, cache, process, transmit,
                    render, and display your User Content solely to provide and
                    improve the service, including generating previews,
                    thumbnails, and AI outputs requested by you.
                  </p>
                  <p>
                    You represent that you have all necessary rights to your
                    User Content and that it does not violate applicable law or
                    third‑party rights (including publicity, privacy, copyright,
                    or trademark).
                  </p>
                </div>
              </section>

              {/* 5. License to Kimu; Feedback */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  5. License to Kimu; Feedback
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    We may reproduce and use de‑identified, aggregated metrics
                    for analytics, performance, and reliability purposes. If you
                    provide suggestions or feedback, you grant Kimu a perpetual,
                    irrevocable, royalty‑free license to use it without
                    restriction.
                  </p>
                </div>
              </section>

              {/* 6. AI Features & Model Providers */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  6. AI Features & Model Providers
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <ul className="list-disc ml-6 space-y-1">
                    <li>
                      Some features send prompts and/or snippets of User Content
                      to third‑party AI providers to fulfill your request.
                    </li>
                    <li>
                      Outputs are provided “as is” and may contain errors.
                      Review AI outputs before use. Do not rely on AI for
                      safety‑critical or legal decisions.
                    </li>
                    <li>
                      You must comply with any additional usage rules required
                      by model providers. We may throttle or disable AI features
                      to protect service quality.
                    </li>
                  </ul>
                </div>
              </section>

              {/* 7. Cloud Projects & Storage */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  7. Cloud Projects & Storage
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <ul className="list-disc ml-6 space-y-1">
                    <li>
                      Cloud projects are stored on secure infrastructure with
                      access controls. Storage limits, rates, and performance
                      may apply.
                    </li>
                    <li>
                      Project sharing grants access to invited collaborators
                      according to permissions you choose. You are responsible
                      for whom you invite.
                    </li>
                    <li>
                      Deleted projects may be temporarily recoverable from
                      backups. We may permanently delete data after a retention
                      window or upon account closure.
                    </li>
                  </ul>
                </div>
              </section>

              {/* 8. Acceptable Use */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  8. Acceptable Use
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <ul className="list-disc ml-6 space-y-1">
                    <li>
                      No illegal content or activity, including IP infringement,
                      harassment, exploitation, or privacy violations.
                    </li>
                    <li>
                      No malware, bots that harm service integrity, excessive
                      load, scraping that circumvents rate limits, or attempts
                      to reverse engineer the service.
                    </li>
                    <li>
                      No uploading of content that is sexually exploitative,
                      hateful, violent, or otherwise violates these Terms or
                      applicable laws.
                    </li>
                  </ul>
                </div>
              </section>

              {/* 9. Payments & Plans */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  9. Payments & Plans
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    Some features may require a paid plan. Prices, features, and
                    billing periods will be presented at checkout. Unless stated
                    otherwise, subscriptions renew automatically until canceled.
                    Taxes may apply.
                  </p>
                </div>
              </section>

              {/* 10. Termination & Suspension */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  10. Termination & Suspension
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <ul className="list-disc ml-6 space-y-1">
                    <li>
                      We may suspend or terminate your access to the hosted
                      service at any time, with or without cause, including for
                      violations of these Terms, risk, abuse, or legal
                      compliance.
                    </li>
                    <li>
                      Upon termination, your license to access the hosted
                      service ends. We may provide a reasonable window to export
                      projects where feasible.
                    </li>
                    <li>
                      Self‑hosted or open‑source use (if available) is governed
                      by the applicable open‑source licenses and is separate
                      from hosted access.
                    </li>
                  </ul>
                </div>
              </section>

              {/* 11. Availability; Changes; Beta */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  11. Availability, Changes & Beta Features
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    We may modify, suspend, or discontinue any feature at any
                    time. Beta or experimental features are provided “as is,”
                    may be throttled, and can be removed without notice.
                  </p>
                </div>
              </section>

              {/* 12. Intellectual Property */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  12. Intellectual Property
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    Kimu, including its UI, code, and design elements, is owned
                    by us or our licensors and is protected by intellectual
                    property laws. Except for rights expressly granted, no
                    rights are transferred to you.
                  </p>
                </div>
              </section>

              {/* 13. Third‑Party Services */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  13. Third‑Party Services
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    Kimu may integrate or link to third‑party services (e.g.,
                    storage, hosting, analytics, AI providers). Your use of
                    those services is subject to their terms and privacy
                    policies. We are not responsible for third‑party services.
                  </p>
                </div>
              </section>

              {/* 14. Disclaimers */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  14. Disclaimers
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    Kimu is provided on an “as is” and “as available” basis
                    without warranties of any kind, express or implied,
                    including merchantability, fitness for a particular purpose,
                    and non‑infringement. We do not guarantee uninterrupted or
                    error‑free operation, or that defects will be corrected.
                  </p>
                </div>
              </section>

              {/* 15. Limitation of Liability */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  15. Limitation of Liability
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    To the maximum extent permitted by law, Kimu and its
                    affiliates will not be liable for any indirect, incidental,
                    special, consequential, exemplary, or punitive damages, or
                    for lost profits, data, or goodwill. Our total liability for
                    any claim relating to the service will not exceed the
                    amounts you paid to us for the service in the 12 months
                    before the claim (or $50 if you did not pay).
                  </p>
                </div>
              </section>

              {/* 16. Indemnification */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  16. Indemnification
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    You agree to indemnify and hold Kimu harmless from any
                    claims, damages, liabilities, and expenses (including
                    reasonable attorney fees) arising from your use of Kimu,
                    your User Content, or your violation of these Terms or
                    applicable law.
                  </p>
                </div>
              </section>

              {/* 17. Governing Law & Disputes */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  17. Governing Law & Dispute Resolution
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    These Terms are governed by the laws applicable in the place
                    where Kimu is organized and operates, without regard to
                    conflict‑of‑laws rules. Where required, mandatory consumer
                    protection laws in your country of residence remain
                    unaffected. Courts in that jurisdiction will have exclusive
                    jurisdiction, unless applicable law provides otherwise.
                  </p>
                </div>
              </section>

              {/* 18. Changes to Terms */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">
                  18. Changes to These Terms
                </h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    We may update these Terms from time to time. When we do, we
                    will post an updated version and effective date. Your
                    continued use of Kimu after changes become effective
                    constitutes acceptance.
                  </p>
                </div>
              </section>

              {/* 19. Contact */}
              <section>
                <h2 className="text-2xl font-bold mb-4 pl-2">19. Contact</h2>
                <div className="space-y-2 ml-8 text-sm text-muted-foreground">
                  <p>
                    Questions? Contact us at{" "}
                    <a href="mailto:robinroy.work@gmail.com" className="underline">
                      robinroy.work@gmail.com
                    </a>{" "}
                    or via <a href="https://discord.com/invite/GSknuxubZK" target="_blank" rel="noreferrer" className="underline">Discord</a>.
                  </p>
                </div>
              </section>
            </div>
          </div>

          {/* Document Footer */}
          <div className="mt-16 pt-6 border-t border-border/20 flex items-center justify-between text-xs md:text-sm">
            <div>
              <span className="uppercase tracking-wider text-muted-foreground">
                Last updated
              </span>{" "}
              <span className="font-medium">{lastUpdated}</span>
            </div>
            <a
              href="/"
              className="inline-flex items-center gap-2 hover:underline font-medium"
              title="Back to Kimu"
            >
              <KimuLogo className="w-4 h-4" /> Return to Kimu
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}



================================================
FILE: app/utils/api.ts
================================================
export const getApiBaseUrl = (fastapi: boolean = false, betterauth: boolean = false): string => {
  const isProduction = process.env.NODE_ENV === "production";

  if (betterauth) {
    return isProduction ? "https://trykimu.com" : "http://localhost:5173";  // frontend  NOTE: this will be deleted, it is repeating logic. It'll be the default.
  } else if (fastapi) {
    return isProduction ? "https://trykimu.com/ai/api" : "http://127.0.0.1:3000";  // fastapi backend
  } else {
    return isProduction ? "https://trykimu.com/render" : "http://localhost:8000";   // remotion render server
  }
};

export const apiUrl = (endpoint: string, fastapi: boolean = false, betterauth: boolean = false): string => {
  const baseUrl = getApiBaseUrl(fastapi, betterauth);
  const path = endpoint.startsWith("/") ? endpoint : `/${endpoint}`;

  return path ? `${baseUrl}${path}` : `${baseUrl}`;
};


================================================
FILE: app/utils/llm-handler.ts
================================================
// because there is only a fixed set of tools the LLM can use in a video editor, we're going to be writing functions for those tools and then calling them from the LLM.

import { type MediaBinItem, type ScrubberState, type TimelineState, type TrackState, type TimelineDataItem, FPS } from "~/components/timeline/types";
import { generateUUID } from "./uuid";

// ============================
// TIMELINE OPERATIONS
// ============================

export function llmAddScrubberToTimeline(
  id: string, 
  mediaBinItems: MediaBinItem[], 
  track: string, 
  dropLeftPx: number, 
  handleDropOnTrack: (item: MediaBinItem, trackId: string, dropLeftPx: number) => void
) {
  // take a scrubber from the media bin and add it to the timeline. It is best to leave the import to media bin to the user.
  const scrubber = mediaBinItems.find(item => item.id === id);
  if (!scrubber) {
    throw new Error(`Scrubber with id ${id} not found`);
  }
  handleDropOnTrack(scrubber, track, dropLeftPx);
}


// everything below is untested and written by claude

export function llmAddScrubberByName(
  name: string,
  mediaBinItems: MediaBinItem[],
  trackNumber: number,
  positionSeconds: number,
  pixelsPerSecond: number,
  handleDropOnTrack: (item: MediaBinItem, trackId: string, dropLeftPx: number) => void
) {
  const scrubber = mediaBinItems.find(item => 
    item.name.toLowerCase().includes(name.toLowerCase())
  );
  if (!scrubber) {
    throw new Error(`Media item with name "${name}" not found`);
  }
  const trackId = `track-${trackNumber}`;
  const dropLeftPx = positionSeconds * pixelsPerSecond;
  handleDropOnTrack(scrubber, trackId, dropLeftPx);
}

export function llmMoveScrubber(
  scrubberId: string,
  newPositionSeconds: number,
  newTrackNumber: number,
  pixelsPerSecond: number,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber) {
    throw new Error(`Scrubber with id ${scrubberId} not found`);
  }
  
  const updatedScrubber: ScrubberState = {
    ...scrubber,
    left: newPositionSeconds * pixelsPerSecond,
    y: newTrackNumber - 1 // Convert to 0-based index
  };
  
  handleUpdateScrubber(updatedScrubber);
}

export function llmResizeScrubber(
  scrubberId: string,
  newDurationSeconds: number,
  pixelsPerSecond: number,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber) {
    throw new Error(`Scrubber with id ${scrubberId} not found`);
  }
  
  const updatedScrubber: ScrubberState = {
    ...scrubber,
    width: newDurationSeconds * pixelsPerSecond
  };
  
  handleUpdateScrubber(updatedScrubber);
}

export function llmDeleteScrubber(
  scrubberId: string,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  // Find and remove scrubber by setting its width to 0 (effectively deleting it)
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber) {
    throw new Error(`Scrubber with id ${scrubberId} not found`);
  }
  
  // Remove by setting width to 0 or marking for deletion
  // Note: In a real implementation, you'd need a proper delete function
  throw new Error("Delete function needs to be implemented in the timeline hook");
}

export function llmDeleteScrubbersInTrack(
  trackNumber: number,
  timeline: TimelineState,
  handleDeleteScrubber: (scrubberId: string) => void
) {
  const trackIndex = trackNumber - 1;
  if (trackIndex < 0 || trackIndex >= timeline.tracks.length) {
    throw new Error(`Track ${trackNumber} does not exist`);
  }
  const track = timeline.tracks[trackIndex];
  // Delete all scrubbers in this track
  track.scrubbers.forEach((scrubber) => {
    handleDeleteScrubber(scrubber.id);
  });
}

// ============================
// TRACK OPERATIONS
// ============================

export function llmAddTrack(
  handleAddTrack: () => void
) {
  handleAddTrack();
}

export function llmDeleteTrack(
  trackId: string,
  handleDeleteTrack: (trackId: string) => void
) {
  handleDeleteTrack(trackId);
}

export function llmDeleteTrackByNumber(
  trackNumber: number,
  timeline: TimelineState,
  handleDeleteTrack: (trackId: string) => void
) {
  const trackIndex = trackNumber - 1; // Convert to 0-based index
  if (trackIndex < 0 || trackIndex >= timeline.tracks.length) {
    throw new Error(`Track ${trackNumber} does not exist`);
  }
  const trackId = timeline.tracks[trackIndex].id;
  handleDeleteTrack(trackId);
}

// ============================
// TIMELINE ZOOM & NAVIGATION
// ============================

export function llmZoomIn(
  handleZoomIn: () => void
) {
  handleZoomIn();
}

export function llmZoomOut(
  handleZoomOut: () => void
) {
  handleZoomOut();
}

export function llmZoomReset(
  handleZoomReset: () => void
) {
  handleZoomReset();
}

export function llmSetTimelinePosition(
  timeSeconds: number,
  pixelsPerSecond: number,
  handleRulerDrag: (positionPx: number) => void
) {
  const positionPx = timeSeconds * pixelsPerSecond;
  handleRulerDrag(positionPx);
}

// ============================
// PLAYBACK CONTROLS
// ============================

export function llmPlay(
  playerRef: React.RefObject<{ play: () => void } | null>
) {
  if (playerRef.current) {
    playerRef.current.play();
  } else {
    throw new Error("Player not available");
  }
}

export function llmPause(
  playerRef: React.RefObject<{ pause: () => void } | null>
) {
  if (playerRef.current) {
    playerRef.current.pause();
  } else {
    throw new Error("Player not available");
  }
}

export function llmTogglePlayback(
  togglePlayback: () => void
) {
  togglePlayback();
}

export function llmSeekToTime(
  timeSeconds: number,
  playerRef: React.RefObject<{ seekTo: (frame: number) => void } | null>
) {
  if (playerRef.current) {
    const frame = Math.round(timeSeconds * FPS);
    playerRef.current.seekTo(frame);
  } else {
    throw new Error("Player not available");
  }
}

export function llmSeekToFrame(
  frame: number,
  playerRef: React.RefObject<{ seekTo: (frame: number) => void } | null>
) {
  if (playerRef.current) {
    playerRef.current.seekTo(frame);
  } else {
    throw new Error("Player not available");
  }
}

// ============================
// MEDIA BIN OPERATIONS
// ============================

export function llmAddMediaFile(
  handleAddMediaClick: () => void
) {
  // Triggers file picker dialog
  handleAddMediaClick();
}

export function llmAddTextToMediaBin(
  textContent: string,
  fontSize: number = 48,
  fontFamily: string = "Arial",
  color: string = "#ffffff",
  textAlign: "left" | "center" | "right" = "center",
  fontWeight: "normal" | "bold" = "normal",
  handleAddTextToBin: (
    textContent: string,
    fontSize: number,
    fontFamily: string,
    color: string,
    textAlign: "left" | "center" | "right",
    fontWeight: "normal" | "bold"
  ) => void
) {
  handleAddTextToBin(textContent, fontSize, fontFamily, color, textAlign, fontWeight);
}

export function llmRemoveMediaFromBin(
  itemId: string,
  mediaBinItems: MediaBinItem[],
  setMediaBinItems: (items: MediaBinItem[]) => void
) {
  const filteredItems = mediaBinItems.filter(item => item.id !== itemId);
  setMediaBinItems(filteredItems);
}

export function llmGetMediaBinItem(
  itemName: string,
  mediaBinItems: MediaBinItem[]
): MediaBinItem | null {
  return mediaBinItems.find(item => 
    item.name.toLowerCase().includes(itemName.toLowerCase())
  ) || null;
}

export function llmListMediaBinItems(
  mediaBinItems: MediaBinItem[]
): string[] {
  return mediaBinItems.map(item => `${item.name} (${item.mediaType})`);
}

// ============================
// COMPOSITION SETTINGS
// ============================

export function llmSetResolution(
  width: number,
  height: number,
  handleWidthChange: (width: number) => void,
  handleHeightChange: (height: number) => void
) {
  handleWidthChange(width);
  handleHeightChange(height);
}

export function llmSetWidth(
  width: number,
  handleWidthChange: (width: number) => void
) {
  handleWidthChange(width);
}

export function llmSetHeight(
  height: number,
  handleHeightChange: (height: number) => void
) {
  handleHeightChange(height);
}

export function llmToggleAutoSize(
  handleAutoSizeChange: (auto: boolean) => void,
  currentState: boolean
) {
  handleAutoSizeChange(!currentState);
}

export function llmSetAutoSize(
  autoSize: boolean,
  handleAutoSizeChange: (auto: boolean) => void
) {
  handleAutoSizeChange(autoSize);
}

// ============================
// RENDERING OPERATIONS
// ============================

export function llmRenderVideo(
  handleRenderClick: () => void
) {
  handleRenderClick();
}

export function llmStartRender(
  getTimelineData: () => TimelineDataItem[],
  timeline: TimelineState,
  width: number | null,
  height: number | null,
  handleRenderVideo: (
    getTimelineData: () => TimelineDataItem[],
    timeline: TimelineState,
    width: number | null,
    height: number | null
  ) => void
) {
  handleRenderVideo(getTimelineData, timeline, width, height);
}

// ============================
// DEBUG & LOGGING
// ============================

export function llmLogTimelineData(
  handleLogTimelineData: () => void
) {
  handleLogTimelineData();
}

export function llmGetTimelineStats(
  timeline: TimelineState
): {
  trackCount: number;
  totalScrubbers: number;
  totalDuration: number;
  scrubbersByTrack: { [trackId: string]: number };
} {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  let maxEndTime = 0;
  
  allScrubbers.forEach(scrubber => {
    const endTime = (scrubber.left + scrubber.width) / 100; // Assuming 100 pixels per second
    if (endTime > maxEndTime) maxEndTime = endTime;
  });

  const scrubbersByTrack: { [trackId: string]: number } = {};
  timeline.tracks.forEach(track => {
    scrubbersByTrack[track.id] = track.scrubbers.length;
  });

  return {
    trackCount: timeline.tracks.length,
    totalScrubbers: allScrubbers.length,
    totalDuration: maxEndTime,
    scrubbersByTrack
  };
}

// ============================
// SCRUBBER PROPERTY EDITING
// ============================

export function llmUpdateScrubberInPlayer(
  scrubberId: string,
  properties: {
    left_player?: number;
    top_player?: number;
    width_player?: number;
    height_player?: number;
  },
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber) {
    throw new Error(`Scrubber with id ${scrubberId} not found`);
  }
  
  const updatedScrubber: ScrubberState = {
    ...scrubber,
    ...properties
  };
  
  handleUpdateScrubber(updatedScrubber);
}

export function llmScaleScrubberInPlayer(
  scrubberId: string,
  scaleX: number,
  scaleY: number,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber) {
    throw new Error(`Scrubber with id ${scrubberId} not found`);
  }
  
  const updatedScrubber: ScrubberState = {
    ...scrubber,
    width_player: scrubber.width_player * scaleX,
    height_player: scrubber.height_player * scaleY
  };
  
  handleUpdateScrubber(updatedScrubber);
}

export function llmPositionScrubberInPlayer(
  scrubberId: string,
  x: number,
  y: number,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  llmUpdateScrubberInPlayer(
    scrubberId,
    { left_player: x, top_player: y },
    timeline,
    handleUpdateScrubber
  );
}

// ============================
// TEXT EDITING OPERATIONS
// ============================

export function llmUpdateTextContent(
  scrubberId: string,
  newTextContent: string,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber || scrubber.mediaType !== "text" || !scrubber.text) {
    throw new Error(`Text scrubber with id ${scrubberId} not found`);
  }
  
  const updatedScrubber: ScrubberState = {
    ...scrubber,
    name: newTextContent,
    text: {
      ...scrubber.text,
      textContent: newTextContent
    }
  };
  
  handleUpdateScrubber(updatedScrubber);
}

export function llmUpdateTextStyle(
  scrubberId: string,
  styleProperties: {
    fontSize?: number;
    fontFamily?: string;
    color?: string;
    textAlign?: "left" | "center" | "right";
    fontWeight?: "normal" | "bold";
  },
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const scrubber = allScrubbers.find(s => s.id === scrubberId);
  if (!scrubber || scrubber.mediaType !== "text" || !scrubber.text) {
    throw new Error(`Text scrubber with id ${scrubberId} not found`);
  }
  
  const updatedScrubber: ScrubberState = {
    ...scrubber,
    text: {
      ...scrubber.text,
      ...styleProperties
    }
  };
  
  handleUpdateScrubber(updatedScrubber);
}

// ============================
// BULK OPERATIONS
// ============================

export function llmSelectAllScrubbers(
  timeline: TimelineState
): string[] {
  return timeline.tracks.flatMap(track => track.scrubbers).map(s => s.id);
}

export function llmSelectScrubbersByType(
  mediaType: "video" | "image" | "text",
  timeline: TimelineState
): string[] {
  return timeline.tracks
    .flatMap(track => track.scrubbers)
    .filter(s => s.mediaType === mediaType)
    .map(s => s.id);
}

export function llmMoveScrubbersByOffset(
  scrubberIds: string[],
  offsetSeconds: number,
  pixelsPerSecond: number,
  timeline: TimelineState,
  handleUpdateScrubber: (updatedScrubber: ScrubberState) => void
) {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  const offsetPx = offsetSeconds * pixelsPerSecond;
  
  scrubberIds.forEach(id => {
    const scrubber = allScrubbers.find(s => s.id === id);
    if (scrubber) {
      const updatedScrubber: ScrubberState = {
        ...scrubber,
        left: Math.max(0, scrubber.left + offsetPx)
      };
      handleUpdateScrubber(updatedScrubber);
    }
  });
}

// ============================
// UTILITY FUNCTIONS
// ============================

export function llmConvertTimeToPixels(
  timeSeconds: number,
  pixelsPerSecond: number
): number {
  return timeSeconds * pixelsPerSecond;
}

export function llmConvertPixelsToTime(
  pixels: number,
  pixelsPerSecond: number
): number {
  return pixels / pixelsPerSecond;
}

export function llmGetTimelineDuration(
  timeline: TimelineState,
  pixelsPerSecond: number
): number {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  let maxEndPosition = 0;
  
  allScrubbers.forEach(scrubber => {
    const endPosition = scrubber.left + scrubber.width;
    if (endPosition > maxEndPosition) {
      maxEndPosition = endPosition;
    }
  });
  
  return maxEndPosition / pixelsPerSecond;
}

export function llmFindScrubberByName(
  name: string,
  timeline: TimelineState
): ScrubberState | null {
  const allScrubbers = timeline.tracks.flatMap(track => track.scrubbers);
  return allScrubbers.find(s => 
    s.name.toLowerCase().includes(name.toLowerCase())
  ) || null;
}

export function llmGetScrubberAtPosition(
  timeSeconds: number,
  trackNumber: number,
  pixelsPerSecond: number,
  timeline: TimelineState
): ScrubberState | null {
  const trackIndex = trackNumber - 1;
  if (trackIndex < 0 || trackIndex >= timeline.tracks.length) {
    return null;
  }
  
  const positionPx = timeSeconds * pixelsPerSecond;
  const track = timeline.tracks[trackIndex];
  
  return track.scrubbers.find(scrubber => 
    positionPx >= scrubber.left && positionPx <= scrubber.left + scrubber.width
  ) || null;
}

// ============================
// THEME & UI OPERATIONS
// ============================

export function llmToggleTheme(
  currentTheme: string,
  setTheme: (theme: string) => void
) {
  const newTheme = currentTheme === "dark" ? "light" : "dark";
  setTheme(newTheme);
}

export function llmSetTheme(
  theme: "light" | "dark",
  setTheme: (theme: string) => void
) {
  setTheme(theme);
}

// ============================
// NAVIGATION OPERATIONS
// ============================

export function llmNavigateToTextEditor(
  navigate: (path: string) => void
) {
  navigate("/editor/text-editor");
}

export function llmNavigateToMediaBin(
  navigate: (path: string) => void
) {
  navigate("/editor/media-bin");
}

export function llmNavigateHome(
  navigate: (path: string) => void
) {
  navigate("/");
}

// ============================
// VALIDATION FUNCTIONS
// ============================

export function llmValidateTimelineForRender(
  timeline: TimelineState
): { isValid: boolean; errors: string[] } {
  const errors: string[] = [];
  
  if (timeline.tracks.length === 0) {
    errors.push("No tracks in timeline");
  }
  
  const hasAnyContent = timeline.tracks.some(track => track.scrubbers.length > 0);
  if (!hasAnyContent) {
    errors.push("No media content in timeline");
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
}

export function llmCheckForCollisions(
  timeline: TimelineState
): { hasCollisions: boolean; collisions: Array<{ scrubber1: string; scrubber2: string; track: string }> } {
  const collisions: Array<{ scrubber1: string; scrubber2: string; track: string }> = [];
  
  timeline.tracks.forEach(track => {
    const scrubbers = track.scrubbers;
    for (let i = 0; i < scrubbers.length; i++) {
      for (let j = i + 1; j < scrubbers.length; j++) {
        const s1 = scrubbers[i];
        const s2 = scrubbers[j];
        
        // Check if they overlap
        if (!(s1.left + s1.width <= s2.left || s2.left + s2.width <= s1.left)) {
          collisions.push({
            scrubber1: s1.id,
            scrubber2: s2.id,
            track: track.id
          });
        }
      }
    }
  });
  
  return {
    hasCollisions: collisions.length > 0,
    collisions
  };
}




================================================
FILE: app/utils/uuid.ts
================================================
/**
 * Generate a UUID with fallback for environments where crypto.randomUUID is not available
 */
export function generateUUID(): string {
  // Check if crypto.randomUUID is available (secure context required)
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  
  // Fallback UUID v4 generation
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
} 


================================================
FILE: app/video-compositions/DragDrop.tsx
================================================
import React, { useCallback, useMemo } from "react";
import { useCurrentScale, Sequence } from "remotion";
import {
  FPS,
  PIXELS_PER_SECOND,
  type ScrubberState,
  type TimelineState,
  type TrackState,
} from "../components/timeline/types";

const HANDLE_SIZE = 10;

export const ResizeHandle: React.FC<{
  type: "top-left" | "top-right" | "bottom-left" | "bottom-right";
  setItem: (updatedScrubber: ScrubberState) => void;
  ScrubberState: ScrubberState;
}> = ({ type, setItem, ScrubberState }) => {
  // console.log("ResizeHandle", JSON.stringify(ScrubberState, null, 2));
  const scale = useCurrentScale();
  const size = Math.round(HANDLE_SIZE / scale);
  const borderSize = 1 / scale;
  const newScrubberStateRef = React.useRef<ScrubberState>(ScrubberState);

  const sizeStyle: React.CSSProperties = useMemo(() => {
    return {
      position: "absolute",
      height: size,
      width: size,
      backgroundColor: "white",
      border: `${borderSize}px solid rgb(59, 130, 246)`, // Use consistent blue
      borderRadius: "2px",
    };
  }, [borderSize, size]);

  const margin = -size / 2 - borderSize;

  const style: React.CSSProperties = useMemo(() => {
    if (type === "top-left") {
      return {
        ...sizeStyle,
        marginLeft: margin,
        marginTop: margin,
        cursor: "nwse-resize",
      };
    }

    if (type === "top-right") {
      return {
        ...sizeStyle,
        marginTop: margin,
        marginRight: margin,
        right: 0,
        cursor: "nesw-resize",
      };
    }

    if (type === "bottom-left") {
      return {
        ...sizeStyle,
        marginBottom: margin,
        marginLeft: margin,
        bottom: 0,
        cursor: "nesw-resize",
      };
    }

    if (type === "bottom-right") {
      return {
        ...sizeStyle,
        marginBottom: margin,
        marginRight: margin,
        right: 0,
        bottom: 0,
        cursor: "nwse-resize",
      };
    }

    throw new Error("Unknown type: " + JSON.stringify(type));
  }, [margin, sizeStyle, type]);

  const onPointerDown = useCallback(
    (e: React.MouseEvent) => {
      // console.log('onPointerDown is called');
      e.stopPropagation();
      if (e.button !== 0) {
        return;
      }

      const initialX = e.clientX;
      const initialY = e.clientY;

      const onPointerMove = (pointerMoveEvent: PointerEvent) => {
        const offsetX = (pointerMoveEvent.clientX - initialX) / scale;
        const offsetY = (pointerMoveEvent.clientY - initialY) / scale;

        const isLeft = type === "top-left" || type === "bottom-left";
        const isTop = type === "top-left" || type === "top-right";

        const newWidth =
          ScrubberState.width_player + (isLeft ? -offsetX : offsetX);
        const newHeight =
          ScrubberState.height_player + (isTop ? -offsetY : offsetY);
        const newLeft = ScrubberState.left_player + (isLeft ? offsetX : 0);
        const newTop = ScrubberState.top_player + (isTop ? offsetY : 0);
        // console.log('newWidth', newWidth);
        // console.log('newHeight', newHeight);
        // console.log('newLeft', newLeft);
        // console.log('newTop', newTop);
        // console.log('ScrubberState before openpointermove update', ScrubberState);
        newScrubberStateRef.current = {
          ...ScrubberState,
          width_player: Math.max(1, Math.round(newWidth)),
          height_player: Math.max(1, Math.round(newHeight)),
          left_player: Math.round(newLeft),
          top_player: Math.round(newTop),
          is_dragging: true,
        };
        setItem(newScrubberStateRef.current);
        // console.log('ScrubberState after openpointermove update',
        //   JSON.stringify(ScrubberState, null, 2)
        // );
      };

      const onPointerUp = () => {
        setItem({
          ...newScrubberStateRef.current,
          is_dragging: false,
        });
        window.removeEventListener("pointermove", onPointerMove);
      };

      window.addEventListener("pointermove", onPointerMove, { passive: true });
      window.addEventListener("pointerup", onPointerUp, {
        once: true,
      });
    },
    [ScrubberState, scale, setItem, type]
  );

  return <div onPointerDown={onPointerDown} style={style} />;
};

export const SelectionOutline: React.FC<{
  ScrubberState: ScrubberState;
  changeItem: (updatedScrubber: ScrubberState) => void;
  setSelectedItem: React.Dispatch<React.SetStateAction<string | null>>;
  selectedItem: string | null;
  isDragging: boolean;
}> = ({
  ScrubberState,
  changeItem,
  setSelectedItem,
  selectedItem,
  isDragging,
}) => {
  // console.log("SelectionOutline", JSON.stringify(ScrubberState, null, 2));
  const scale = useCurrentScale();
  const scaledBorder = Math.ceil(2 / scale);
  const newScrubberStateRef = React.useRef<ScrubberState>(ScrubberState);

  const [hovered, setHovered] = React.useState(false);

  const onMouseEnter = useCallback(() => {
    setHovered(true);
  }, []);

  const onMouseLeave = useCallback(() => {
    setHovered(false);
  }, []);

  const isSelected = ScrubberState.id === selectedItem;
  // console.log("isSelected", isSelected);
  const style: React.CSSProperties = useMemo(() => {
    return {
      width: ScrubberState.width_player,
      height: ScrubberState.height_player,
      left: ScrubberState.left_player,
      top: ScrubberState.top_player,
      position: "absolute",
      outline:
        (hovered && !isDragging) || isSelected
          ? `${scaledBorder}px solid rgb(59, 130, 246)` // Use a consistent blue
          : undefined,
      userSelect: "none",
      touchAction: "none",
    };
  }, [ScrubberState, hovered, isDragging, isSelected, scaledBorder]);

  const startDragging = useCallback(
    (e: PointerEvent | React.MouseEvent) => {
      const initialX = e.clientX;
      const initialY = e.clientY;

      const onPointerMove = (pointerMoveEvent: PointerEvent) => {
        const offsetX = (pointerMoveEvent.clientX - initialX) / scale;
        const offsetY = (pointerMoveEvent.clientY - initialY) / scale;
        newScrubberStateRef.current = {
          ...ScrubberState,
          left_player: Math.round(ScrubberState.left_player + offsetX),
          top_player: Math.round(ScrubberState.top_player + offsetY),
          is_dragging: true,
        };
        changeItem(newScrubberStateRef.current);
      };

      const onPointerUp = () => {
        // console.log(
        //   "onPointerUp is called",
        //   JSON.stringify(ScrubberState, null, 2)
        // );
        changeItem({
          ...newScrubberStateRef.current,
          is_dragging: false,
        });
        window.removeEventListener("pointermove", onPointerMove);
      };

      window.addEventListener("pointermove", onPointerMove, { passive: true });

      window.addEventListener("pointerup", onPointerUp, {
        once: true,
      });
    },
    [ScrubberState, scale, changeItem]
  );

  const onPointerDown = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      if (e.button !== 0) {
        return;
      }

      console.log("onPointerDown is called", ScrubberState.id);
      setSelectedItem(ScrubberState.id);
      startDragging(e);
    },
    [ScrubberState.id, setSelectedItem, startDragging]
  );

  return (
    <div
      onPointerDown={onPointerDown}
      onPointerEnter={onMouseEnter}
      onPointerLeave={onMouseLeave}
      style={style}
    >
      {isSelected ? (
        <>
          <ResizeHandle
            ScrubberState={ScrubberState}
            setItem={changeItem}
            type="top-left"
          />
          <ResizeHandle
            ScrubberState={ScrubberState}
            setItem={changeItem}
            type="top-right"
          />
          <ResizeHandle
            ScrubberState={ScrubberState}
            setItem={changeItem}
            type="bottom-left"
          />
          <ResizeHandle
            ScrubberState={ScrubberState}
            setItem={changeItem}
            type="bottom-right"
          />
        </>
      ) : null}
    </div>
  );
};

const displaySelectedItemOnTop = (
  items: ScrubberState[],
  selectedItem: string | null
): ScrubberState[] => {
  const selectedItems = items.filter(
    (ScrubberState) => ScrubberState.id === selectedItem
  );
  const unselectedItems = items.filter(
    (ScrubberState) => ScrubberState.id !== selectedItem
  );

  return [...unselectedItems, ...selectedItems];
};

export const layerContainer: React.CSSProperties = {
  overflow: "hidden",
};

export const outer: React.CSSProperties = {
  backgroundColor: "#000000", // Black background for video preview
};

export const SortedOutlines: React.FC<{
  timeline: TimelineState;
  selectedItem: string | null;
  setSelectedItem: React.Dispatch<React.SetStateAction<string | null>>;
  handleUpdateScrubber: (updateScrubber: ScrubberState) => void;
}> = ({ timeline, selectedItem, setSelectedItem, handleUpdateScrubber }) => {
  // const items = timeline.tracks.flatMap((track: TrackState) => track.scrubbers);
  // console.log('timeline', timeline);
  const itemsToDisplay = React.useMemo(() => {
    return displaySelectedItemOnTop(
      timeline.tracks.flatMap((track: TrackState) => track.scrubbers),
      selectedItem
    );
  }, [timeline, selectedItem]);

  const isDragging = React.useMemo(
    () =>
      timeline.tracks
        .flatMap((track: TrackState) => track.scrubbers)
        .some((ScrubberState) => ScrubberState.is_dragging),
    [timeline]
  );

  return itemsToDisplay.map((ScrubberState) => {
    return (
      <Sequence
        key={ScrubberState.id}
        from={Math.round((ScrubberState.left / PIXELS_PER_SECOND) * FPS)}
        durationInFrames={Math.round(
          (ScrubberState.width / PIXELS_PER_SECOND) * FPS
        )}
        layout="none"
      >
        <SelectionOutline
          changeItem={handleUpdateScrubber}
          ScrubberState={ScrubberState}
          setSelectedItem={setSelectedItem}
          selectedItem={selectedItem}
          isDragging={isDragging}
        />
      </Sequence>
    );
  });
};



================================================
FILE: app/video-compositions/VideoPlayer.tsx
================================================
import { Player, type PlayerRef } from "@remotion/player";
import { Sequence, AbsoluteFill, Img, Video, Audio } from "remotion";
import {
  linearTiming,
  springTiming,
  TransitionSeries,
  type TransitionPresentation,
} from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { iris } from "@remotion/transitions/iris";
import { wipe } from "@remotion/transitions/wipe";
import { flip } from "@remotion/transitions/flip";
import { slide } from "@remotion/transitions/slide";
import React from "react";
import {
  FPS,
  PIXELS_PER_SECOND,
  type ScrubberState,
  type TimelineDataItem,
  type TimelineState,
  type Transition,
} from "../components/timeline/types";
import { SortedOutlines, layerContainer, outer } from "./DragDrop";

type TimelineCompositionProps = {
  timelineData: TimelineDataItem[];
  isRendering: boolean; // it's either render (True) or preview (False)
  selectedItem: string | null;
  setSelectedItem: React.Dispatch<React.SetStateAction<string | null>>;
  timeline: TimelineState;
  handleUpdateScrubber: (updateScrubber: ScrubberState) => void;
  getPixelsPerSecond: number | (() => number);
};

// props for the preview mode player
export type VideoPlayerProps = {
  timelineData: TimelineDataItem[];
  durationInFrames: number; // this is for the player to know how long to render (used in preview mode)
  ref: React.Ref<PlayerRef>;
  compositionWidth: number | null; // if null, the player width = max(width)
  compositionHeight: number | null; // if null, the player height = max(height)
  timeline: TimelineState;
  handleUpdateScrubber: (updateScrubber: ScrubberState) => void;
  selectedItem: string | null;
  setSelectedItem: React.Dispatch<React.SetStateAction<string | null>>;
  getPixelsPerSecond: number | (() => number);
};

export function TimelineComposition({
  timelineData,
  isRendering,
  selectedItem,
  setSelectedItem,
  timeline,
  handleUpdateScrubber,
  getPixelsPerSecond,
}: TimelineCompositionProps) {
  // Resolve pixels per second based on rendering mode
  const resolvedPixelsPerSecond = isRendering
    ? (getPixelsPerSecond as number)
    : (getPixelsPerSecond as () => number)();
  // Get all transitions from timelineData
  const allTransitions = timelineData[0].transitions;

  // Step 1: Group scrubbers by trackIndex
  const trackGroups: {
    [trackIndex: number]: {
      content: TimelineDataItem["scrubbers"][0];
      type: string;
    }[];
  } = {};

  for (const timelineItem of timelineData) {
    for (const scrubber of timelineItem.scrubbers) {
      if (!trackGroups[scrubber.trackIndex]) {
        trackGroups[scrubber.trackIndex] = [];
      }
      trackGroups[scrubber.trackIndex].push({
        content: scrubber,
        type: "scrubber",
      });
    }
  }

  // Step 2: Sort scrubbers within each track by startTime
  for (const trackIndex in trackGroups) {
    trackGroups[parseInt(trackIndex)].sort(
      (a, b) => a.content.startTime - b.content.startTime
    );
  }

  // Helper function to create media content
  const createMediaContent = (scrubber: TimelineDataItem['scrubbers'][0] | ScrubberState): React.ReactNode => {
    let content: React.ReactNode = null;

    switch (scrubber.mediaType) {
      case "text":
        content = (
          <AbsoluteFill
            style={{
              left: scrubber.left_player,
              top: scrubber.top_player,
              width: scrubber.width_player,
              height: scrubber.height_player,
              justifyContent: "center",
              alignItems: "center",
            }}
          >
            <div
              style={{
                textAlign: scrubber.text?.textAlign || "center",
                width: "100%",
              }}
            >
              <p
                style={{
                  color: scrubber.text?.color || "white",
                  fontSize: scrubber.text?.fontSize
                    ? `${scrubber.text.fontSize}px`
                    : "48px",
                  fontFamily: scrubber.text?.fontFamily || "Arial, sans-serif",
                  fontWeight: scrubber.text?.fontWeight || "normal",
                  margin: 0,
                  padding: "20px",
                }}
              >
                {scrubber.text?.textContent || ""}
              </p>
            </div>
          </AbsoluteFill>
        );
        break;
      case "image": {
        const imageUrl = isRendering
          ? scrubber.mediaUrlRemote || scrubber.mediaUrlLocal
          : scrubber.mediaUrlLocal || scrubber.mediaUrlRemote;
        content = (
          <AbsoluteFill
            style={{
              left: scrubber.left_player,
              top: scrubber.top_player,
              width: scrubber.width_player,
              height: scrubber.height_player,
            }}
          >
            <Img src={imageUrl!} />
          </AbsoluteFill>
        );
        break;
      }
      case "video": {
        const videoUrl = isRendering
          ? scrubber.mediaUrlRemote || scrubber.mediaUrlLocal
          : scrubber.mediaUrlLocal || scrubber.mediaUrlRemote;
        content = (
          <AbsoluteFill
            style={{
              left: scrubber.left_player,
              top: scrubber.top_player,
              width: scrubber.width_player,
              height: scrubber.height_player,
            }}
          >
            <Video
              src={videoUrl!}
              trimBefore={scrubber.trimBefore || undefined}
              trimAfter={scrubber.trimAfter || undefined}
            />
          </AbsoluteFill>
        );
        break;
      }
      case "audio": {
        const audioUrl = isRendering
          ? scrubber.mediaUrlRemote || scrubber.mediaUrlLocal
          : scrubber.mediaUrlLocal || scrubber.mediaUrlRemote;
        content = (
          <Audio
            src={audioUrl!}
            trimBefore={scrubber.trimBefore || undefined}
            trimAfter={scrubber.trimAfter || undefined}
          />
        );
        break;
      }
      default:
        console.warn(`Unknown media type: ${scrubber.mediaType}`);
        break;
    }

    return content;
  };

  // Helper function to get transition presentation
  const getTransitionPresentation = (transition: Transition) => {
    switch (transition.presentation) {
      case "fade":
        return fade();
      case "wipe":
        return wipe();
      case "slide":
        return slide();
      case "flip":
        return flip();
      case "iris":
        return iris({ width: 1000, height: 1000 });
    }
  };

  // Helper function to get transition timing
  const getTransitionTiming = (transition: Transition) => {
    switch (transition.timing) {
      case "spring":
        return springTiming({ durationInFrames: transition.durationInFrames });
      case "linear":
        return linearTiming({ durationInFrames: transition.durationInFrames });
      default:
        return linearTiming({ durationInFrames: transition.durationInFrames });
    }
  };

  // Step 3 & 4: Create tracks with gaps filled and transitions added
  const trackElements: React.ReactNode[] = [];

  for (const trackIndex in trackGroups) {
    const trackIndexNum = parseInt(trackIndex);
    const scrubbers = trackGroups[trackIndexNum];

    if (scrubbers.length === 0) continue;

    const transitionSeriesElements: React.ReactNode[] = [];
    let totalDurationInFrames = 0;

    // Calculate total duration for this track
    if (scrubbers.length > 0) {
      const lastScrubber = scrubbers[scrubbers.length - 1].content;
      totalDurationInFrames = Math.round(lastScrubber.endTime * FPS);
    }

    for (let i = 0; i < scrubbers.length; i++) {
      const scrubber = scrubbers[i].content;
      const isFirstScrubber = i === 0;
      const isLastScrubber = i === scrubbers.length - 1;

      // Add gap before first scrubber if it doesn't start at 0
      if (isFirstScrubber && scrubber.startTime > 0) {
        transitionSeriesElements.push(
          <TransitionSeries.Sequence
            key={`gap-start-${trackIndex}`}
            durationInFrames={Math.max(Math.round(scrubber.startTime * FPS), 1)}
          >
            <AbsoluteFill style={{ backgroundColor: "transparent" }} />
          </TransitionSeries.Sequence>
        );
      }

      // Add left transition if exists (only for first scrubber)
      if (
        isFirstScrubber &&
        scrubber.left_transition_id &&
        allTransitions[scrubber.left_transition_id]
      ) {
        const transition = allTransitions[scrubber.left_transition_id];
        transitionSeriesElements.push(
          <TransitionSeries.Transition
            key={`left-transition-${scrubber.id}`}
            // @ts-expect-error - NOTE: typescript is being stoopid. The fix is nasty so let it be. it is not an error.
            presentation={getTransitionPresentation(transition)}
            timing={getTransitionTiming(transition)}
          />
        );
      }

      // NOTE: groupped nested transitions are not supported yet. I'm too tired to implement it. idc. just dont use it. wtv.
      // Process grouped scrubbers with transitions, then use stack approach for recursion
      if (scrubber.mediaType === "groupped_scrubber") {
        // For grouped scrubbers, handle transitions between grouped items
        const groupedScrubbers = scrubber.groupped_scrubbers || [];

        for (let j = 0; j < groupedScrubbers.length; j++) {
          const grouppedScrubber = groupedScrubbers[j];
          
          // Add left transition for the first grouped scrubber
          if (j === 0 && grouppedScrubber.left_transition_id && allTransitions[grouppedScrubber.left_transition_id]) {
            const transition = allTransitions[grouppedScrubber.left_transition_id];
            transitionSeriesElements.push(
              <TransitionSeries.Transition
                key={`grouped-${grouppedScrubber.id}-left-transition`}
                // @ts-expect-error - NOTE: typescript is being stoopid. The fix is nasty so let it be. it is not an error.
                presentation={getTransitionPresentation(transition)}
                timing={getTransitionTiming(transition)}
              />
            );
          }

          // Use stack approach for each grouped scrubber to handle potential nesting
          const scrubberStack: Array<{
            scrubber: TimelineDataItem['scrubbers'][0] | ScrubberState;
            keyPrefix: string;
            durationCalculation: () => number;
          }> = [];

          scrubberStack.push({
            scrubber: grouppedScrubber,
            keyPrefix: `grouped-${grouppedScrubber.id}`,
            durationCalculation: () => Math.max(Math.round((grouppedScrubber.width / resolvedPixelsPerSecond) * FPS), 1)
          });

          // Process the stack for this grouped scrubber
          while (scrubberStack.length > 0) {
            const stackItem = scrubberStack.pop()!;
            const { scrubber: currentScrubber, keyPrefix, durationCalculation } = stackItem;

            if (currentScrubber.mediaType === "groupped_scrubber") {
              // Add nested grouped scrubbers to the stack in reverse order
              for (let k = (currentScrubber.groupped_scrubbers || []).length - 1; k >= 0; k--) {
                const nestedScrubber = (currentScrubber.groupped_scrubbers || [])[k];
                scrubberStack.push({
                  scrubber: nestedScrubber,
                  keyPrefix: `${keyPrefix}-nested-${nestedScrubber.id}`,
                  durationCalculation: () => Math.max(Math.round((nestedScrubber.width / resolvedPixelsPerSecond) * FPS), 1)
                });
              }
            } else {
              // Create media content for non-grouped scrubber
              const mediaContent = createMediaContent(currentScrubber);
              if (mediaContent) {
                transitionSeriesElements.push(
                  <TransitionSeries.Sequence
                    key={keyPrefix}
                    durationInFrames={durationCalculation()}
                  >
                    {mediaContent}
                  </TransitionSeries.Sequence>
                );
              }
            }
          }

          // Add right transition between grouped scrubbers or at the end
          if (grouppedScrubber.right_transition_id && allTransitions[grouppedScrubber.right_transition_id]) {
            const transition = allTransitions[grouppedScrubber.right_transition_id];
            transitionSeriesElements.push(
              <TransitionSeries.Transition
                key={`grouped-${grouppedScrubber.id}-right-transition`}
                // @ts-expect-error - NOTE: typescript is being stoopid. The fix is nasty so let it be. it is not an error.
                presentation={getTransitionPresentation(transition)}
                timing={getTransitionTiming(transition)}
              />
            );
          }
        }
      } else {
        // Process regular scrubbers using the stack approach
        const scrubberStack: Array<{
          scrubber: TimelineDataItem['scrubbers'][0] | ScrubberState;
          keyPrefix: string;
          durationCalculation: () => number;
        }> = [];

        scrubberStack.push({
          scrubber: scrubber,
          keyPrefix: `scrubber-${scrubber.id}`,
          durationCalculation: () => Math.max(Math.round(scrubber.duration * FPS), 1)
        });

        // Process the stack
        while (scrubberStack.length > 0) {
          const stackItem = scrubberStack.pop()!;
          const { scrubber: currentScrubber, keyPrefix, durationCalculation } = stackItem;

          if (currentScrubber.mediaType === "groupped_scrubber") {
            // Add nested grouped scrubbers to the stack in reverse order
            for (let k = (currentScrubber.groupped_scrubbers || []).length - 1; k >= 0; k--) {
              const nestedScrubber = (currentScrubber.groupped_scrubbers || [])[k];
              scrubberStack.push({
                scrubber: nestedScrubber,
                keyPrefix: `${keyPrefix}-nested-${nestedScrubber.id}`,
                durationCalculation: () => Math.max(Math.round((nestedScrubber.width / resolvedPixelsPerSecond) * FPS), 1)
              });
            }
          } else {
            // Create media content for non-grouped scrubber
            const mediaContent = createMediaContent(currentScrubber);
            if (mediaContent) {
              transitionSeriesElements.push(
                <TransitionSeries.Sequence
                  key={keyPrefix}
                  durationInFrames={durationCalculation()}
                >
                  {mediaContent}
                </TransitionSeries.Sequence>
              );
            }
          }
        }
      }

      // Add right transition if exists
      if (
        scrubber.right_transition_id &&
        allTransitions[scrubber.right_transition_id]
      ) {
        const transition = allTransitions[scrubber.right_transition_id];
        transitionSeriesElements.push(
          <TransitionSeries.Transition
            key={`right-transition-${scrubber.id}`}
            // @ts-expect-error - NOTE: typescript is being stoopid. The fix is nasty so let it be. it is not an error.
            presentation={getTransitionPresentation(transition)}
            timing={getTransitionTiming(transition)}
          />
        );
      }

      // Add gap between scrubbers if there's a gap
      if (!isLastScrubber) {
        const nextScrubber = scrubbers[i + 1].content;
        const gapStart = scrubber.endTime;
        const gapEnd = nextScrubber.startTime;

        if (gapEnd > gapStart) {
          const gapDuration = gapEnd - gapStart;
          transitionSeriesElements.push(
            <TransitionSeries.Sequence
              key={`gap-${trackIndex}-${i}`}
              durationInFrames={Math.max(Math.round(gapDuration * FPS), 1)}
            >
              <AbsoluteFill style={{ backgroundColor: "transparent" }} />
            </TransitionSeries.Sequence>
          );
        }
      }
    }

    // Create the track sequence
    if (transitionSeriesElements.length > 0) {
      trackElements.push(
        <Sequence
          key={`track-${trackIndex}`}
          durationInFrames={totalDurationInFrames}
        >
          <TransitionSeries>{transitionSeriesElements}</TransitionSeries>
        </Sequence>
      );
    }
  }

  if (isRendering) {
    return (
      <AbsoluteFill style={outer}>
        <AbsoluteFill style={layerContainer}>{trackElements}</AbsoluteFill>
      </AbsoluteFill>
    );
  } else {
    return (
      <AbsoluteFill style={outer}>
        <AbsoluteFill style={layerContainer}>{trackElements}</AbsoluteFill>
        <SortedOutlines
          handleUpdateScrubber={handleUpdateScrubber}
          selectedItem={selectedItem}
          timeline={timeline}
          setSelectedItem={setSelectedItem}
        />
      </AbsoluteFill>
    );
  }
}

export function VideoPlayer({
  timelineData,
  durationInFrames,
  ref,
  compositionWidth,
  compositionHeight,
  timeline,
  handleUpdateScrubber,
  selectedItem,
  setSelectedItem,
  getPixelsPerSecond,
}: VideoPlayerProps) {
  // Calculate composition width if not provided
  if (compositionWidth === null) {
    let maxWidth = 0;
    for (const item of timelineData) {
      for (const scrubber of item.scrubbers) {
        if (scrubber.media_width !== null && scrubber.media_width > maxWidth) {
          maxWidth = scrubber.media_width;
        }
      }
    }
    compositionWidth = maxWidth || 1920; // Default to 1920 if no media found
  }

  // Calculate composition height if not provided
  if (compositionHeight === null) {
    let maxHeight = 0;
    for (const item of timelineData) {
      for (const scrubber of item.scrubbers) {
        if (
          scrubber.media_height !== null &&
          scrubber.media_height > maxHeight
        ) {
          maxHeight = scrubber.media_height;
        }
      }
    }
    compositionHeight = maxHeight || 1080; // Default to 1080 if no media found
  }

  // Guard against invalid dimensions (e.g., user typed 0, only-audio timelines)
  const safeWidth =
    !compositionWidth || compositionWidth <= 0 ? 1920 : compositionWidth;
  const safeHeight =
    !compositionHeight || compositionHeight <= 0 ? 1080 : compositionHeight;
  const safeDuration = Math.max(1, durationInFrames || 1);

  return (
    <Player
      ref={ref}
      component={TimelineComposition}
      inputProps={{
        timelineData,
        durationInFrames,
        isRendering: false,
        selectedItem,
        setSelectedItem,
        timeline,
        handleUpdateScrubber,
        getPixelsPerSecond,
      }}
      durationInFrames={safeDuration}
      compositionWidth={safeWidth}
      compositionHeight={safeHeight}
      fps={30}
      style={{
        width: "100%",
        height: "100%",
        position: "relative",
        zIndex: 1,
      }}
      acknowledgeRemotionLicense
    />
  );
}



================================================
FILE: app/videorender/Composition.tsx
================================================
import { Composition, getInputProps } from 'remotion';
import { TimelineComposition } from '../video-compositions/VideoPlayer';

export default function RenderComposition() {
    const inputProps = getInputProps();
    console.log("Input props:", inputProps);
    return (
        <Composition
            id="TimelineComposition"
            component={TimelineComposition}
            durationInFrames={(inputProps.durationInFrames as number) ?? 300}   // this is for some hacky reason i forgot. welp.
            fps={30}
            width={inputProps.compositionWidth as number}
            height={inputProps.compositionHeight as number}
            defaultProps={{                 // idek why this is forced. We can't pass defaultprops to the composition anyways🤷
                timelineData: [
                    {
                        scrubbers: [
                            {
                                id: "1-1",
                                startTime: 0,
                                endTime: 3,
                                duration: 3,
                                mediaType: "text",
                                media_width: 80,
                                media_height: 80,
                                mediaUrlLocal: null,
                                mediaUrlRemote: null,
                                text: {
                                    textContent: "Hello, world!",
                                    fontSize: 16,
                                    fontFamily: "Arial",
                                    color: "#000000",
                                    textAlign: "left",
                                    fontWeight: "normal",
                                    template: null
                                },
                                left_player: 100,
                                top_player: 100,
                                width_player: 200,
                                height_player: 200,
                                trackIndex: 0,
                                trimBefore: null,
                                trimAfter: null,
                                left_transition_id: null,
                                right_transition_id: null,
                                groupped_scrubbers: null,
                            },
                        ],
                        transitions: {},
                    }
                ],
                isRendering: false,
                selectedItem: null,
                setSelectedItem: () => { },
                timeline: { tracks: [] },
                handleUpdateScrubber: () => { },
                getPixelsPerSecond: () => 100,
            }}
        />
    )
}


================================================
FILE: app/videorender/index.ts
================================================
import { registerRoot } from 'remotion';
import RenderComposition from './Composition';


registerRoot(RenderComposition);


================================================
FILE: app/videorender/videorender.ts
================================================
import { bundle } from '@remotion/bundler';
import { renderMedia, selectComposition } from '@remotion/renderer';
import path from 'path';
import express, { type Request, type Response } from 'express';
import cors from 'cors';
import fs from 'fs';
import multer from 'multer';

// The composition you want to render
const compositionId = 'TimelineComposition';

// You only have to create a bundle once, and you may reuse it
// for multiple renders that you can parametrize using input props.
const bundleLocation = await bundle({
  entryPoint: path.resolve('./app/videorender/index.ts'),
  // If you have a webpack override in remotion.config.ts, pass it here as well.
  webpackOverride: (config) => config,
});

console.log(bundleLocation);

// Ensure output directory exists
if (!fs.existsSync('out')) {
  fs.mkdirSync('out', { recursive: true });
}

const app = express();
app.use(express.json());
app.use(cors());

// Static file serving for the out/ directory
app.use('/media', express.static(path.resolve('out'), {
  dotfiles: 'deny',
  index: false
}));

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Ensure out directory exists
    if (!fs.existsSync('out')) {
      fs.mkdirSync('out', { recursive: true });
    }
    cb(null, 'out/');
  },
  filename: (req, file, cb) => {
    // Generate unique filename with timestamp
    const timestamp = Date.now();
    const originalName = file.originalname;
    const extension = path.extname(originalName);
    const nameWithoutExt = path.basename(originalName, extension);
    const uniqueName = `${nameWithoutExt}_${timestamp}${extension}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: 500 * 1024 * 1024, // 500MB limit (we'll do no limits later)
  },
  fileFilter: (req, file, cb) => {
    // Accept common media file types
    const allowedTypes = /\.(mp4|webm|mov|avi|mkv|flv|wmv|m4v|mp3|wav|aac|ogg|flac|jpg|jpeg|png|gif|bmp|webp)$/i;
    if (allowedTypes.test(file.originalname)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only media files are allowed.'));
    }
  }
});

// List files in out/ directory
app.get('/media', (req: Request, res: Response): void => {
  try {
    const outDir = path.resolve('out');
    if (!fs.existsSync(outDir)) {
      res.json({ files: [] });
      return;
    }

    const files = fs.readdirSync(outDir).map(filename => {
      const filePath = path.join(outDir, filename);
      const stats = fs.statSync(filePath);
      return {
        name: filename,
        url: `/media/${encodeURIComponent(filename)}`,
        size: stats.size,
        modified: stats.mtime,
        isDirectory: stats.isDirectory()
      };
    }).filter(file => !file.isDirectory); // Only show files, not directories

    res.json({ files });
  } catch (error) {
    console.error('Error listing files:', error);
    res.status(500).json({ error: 'Failed to list files' });
  }
});

// File upload endpoint
app.post('/upload', upload.single('media'), (req: Request, res: Response): void => {
  try {
    if (!req.file) {
      res.status(400).json({ error: 'No file uploaded' });
      return;
    }

    const fileUrl = `/media/${encodeURIComponent(req.file.filename)}`;
    const fullUrl = `http://localhost:${port}${fileUrl}`; // Direct backend URL for Remotion

    console.log(`📁 File uploaded: ${req.file.originalname} -> ${req.file.filename}`);

    res.json({
      success: true,
      filename: req.file.filename,
      originalName: req.file.originalname,
      url: fileUrl,
      fullUrl: fullUrl,
      size: req.file.size,
      path: req.file.path
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'File upload failed' });
  }
});

// Bulk file upload endpoint
app.post('/upload-multiple', upload.array('media', 10), (req: Request, res: Response): void => {
  try {
    if (!req.files || req.files.length === 0) {
      res.status(400).json({ error: 'No files uploaded' });
      return;
    }

    const uploadedFiles = (req.files as Express.Multer.File[]).map(file => ({
      filename: file.filename,
      originalName: file.originalname,
      url: `/media/${encodeURIComponent(file.filename)}`,
      fullUrl: `http://localhost:${port}/media/${encodeURIComponent(file.filename)}`, // Direct backend URL for Remotion
      size: file.size,
      path: file.path
    }));

    console.log(`📁 ${uploadedFiles.length} files uploaded`);

    res.json({
      success: true,
      files: uploadedFiles
    });
  } catch (error) {
    console.error('Bulk upload error:', error);
    res.status(500).json({ error: 'Bulk file upload failed' });
  }
});

// Clone/copy media file endpoint
app.post('/clone-media', (req: Request, res: Response): void => {
  try {
    const { filename, originalName, suffix } = req.body;
    
    if (!filename) {
      res.status(400).json({ error: 'Filename is required' });
      return;
    }
    
    const decodedFilename = decodeURIComponent(filename);
    const sourcePath = path.resolve('out', decodedFilename);
    
    // Security check - ensure source file is in the out directory
    if (!sourcePath.startsWith(path.resolve('out'))) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }
    
    if (!fs.existsSync(sourcePath)) {
      res.status(404).json({ error: 'Source file not found' });
      return;
    }
    
    // Generate new filename with timestamp and suffix
    const timestamp = Date.now();
    const sourceExtension = path.extname(decodedFilename);
    const sourceNameWithoutExt = path.basename(decodedFilename, sourceExtension);
    const newFilename = `${sourceNameWithoutExt}_${suffix}_${timestamp}${sourceExtension}`;
    const destPath = path.resolve('out', newFilename);
    
    // Copy the file
    fs.copyFileSync(sourcePath, destPath);
    
    const fileStats = fs.statSync(destPath);
    const fileUrl = `/media/${encodeURIComponent(newFilename)}`;
    const fullUrl = `http://localhost:${port}${fileUrl}`;
    
    console.log(`📋 File cloned: ${decodedFilename} -> ${newFilename}`);
    
    res.json({
      success: true,
      filename: newFilename,
      originalName: originalName || decodedFilename,
      url: fileUrl,
      fullUrl: fullUrl,
      size: fileStats.size,
      path: destPath
    });
  } catch (error) {
    console.error('Clone error:', error);
    res.status(500).json({ error: 'Failed to clone file' });
  }
});

// Delete file endpoint
app.delete('/media/:filename', (req: Request, res: Response): void => {
  try {
    const filename = decodeURIComponent(req.params.filename);
    const filePath = path.resolve('out', filename);
    
    // Security check - ensure file is in the out directory
    if (!filePath.startsWith(path.resolve('out'))) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }
    
    if (!fs.existsSync(filePath)) {
      res.status(404).json({ error: 'File not found' });
      return;
    }
    
    fs.unlinkSync(filePath);
    console.log(`🗑️ File deleted: ${filename}`);
    
    res.json({ 
      success: true, 
      message: `File ${filename} deleted successfully` 
    });
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({ error: 'Failed to delete file' });
  }
});

// Health check endpoint to monitor system resources
app.get('/health', (req, res) => {
  const used = process.memoryUsage();
  res.json({
    status: 'ok',
    memory: {
      rss: `${Math.round(used.rss / 1024 / 1024)} MB`,
      heapTotal: `${Math.round(used.heapTotal / 1024 / 1024)} MB`,
      heapUsed: `${Math.round(used.heapUsed / 1024 / 1024)} MB`,
    },
    uptime: `${Math.round(process.uptime())} seconds`
  });
});

app.post('/render', async (req, res) => {
  try {
    // Get input props from POST body
    const inputProps = {
      timelineData: req.body.timelineData,
      durationInFrames: req.body.durationInFrames,
      compositionWidth: req.body.compositionWidth,
      compositionHeight: req.body.compositionHeight,
      getPixelsPerSecond: req.body.getPixelsPerSecond,
      isRendering: true,
    };

    // console.log("Input props:", typeof inputProps.compositionWidth);
    console.log("Input props:", JSON.stringify(inputProps, null, 2));
    // Get the composition you want to render
    const composition = await selectComposition({
      serveUrl: bundleLocation,
      id: compositionId,
      inputProps,
    });

    // const maxFrames = Math.min(composition.durationInFrames, 150); // Max 5 seconds at 30fps
    // console.log(`Starting ULTRA low-resource render. Limiting to ${maxFrames} frames (${maxFrames / 30}s)`);

    // Render optimized for 4vCPU, 8GB RAM server
    await renderMedia({
      composition,
      serveUrl: bundleLocation,
      codec: 'h264',
      outputLocation: `out/${compositionId}.mp4`,
      inputProps,
      // Optimized settings for server hardware
      concurrency: 3, // Use 3 cores, leave 1 for system
      verbose: true,
      logLevel: 'info', // More detailed logging for server monitoring
      // Balanced encoding settings for server performance
      ffmpegOverride: ({ args }) => {
        return [
          ...args,
          '-preset', 'fast', // Good balance of speed and quality
          '-crf', '28', // Better quality than ultrafast setting
          '-threads', '3', // Use 3 threads for encoding
          '-tune', 'film', // Better quality for general content
          '-x264-params', 'ref=3:me=hex:subme=6:trellis=1', // Better quality settings
          '-g', '30', // Standard keyframe interval
          '-bf', '2', // Allow some B-frames for better compression
          '-maxrate', '5M', // Limit bitrate to prevent memory issues
          '-bufsize', '10M', // Buffer size for rate control
        ];
      },
      timeoutInMilliseconds: 900000, // 15 minute timeout for longer videos
    });

    console.log('✅ Render completed successfully');
    res.sendFile(path.resolve(`out/${compositionId}.mp4`));

  } catch (err) {
    console.error('❌ Render failed:', err);

    // Clean up failed renders
    try {
      const outputPath = `out/${compositionId}.mp4`;
      if (fs.existsSync(outputPath)) {
        fs.unlinkSync(outputPath);
        console.log('🧹 Cleaned up partial file');
      }
    } catch (cleanupErr) {
      console.warn('⚠️ Could not clean up:', cleanupErr);
    }

    res.status(500).json({
      error: 'Video rendering failed',
      message: 'Your laptop might be under heavy load. Try closing other apps and rendering again.',
      tip: 'Videos are limited to 5 seconds at half resolution for performance.'
    });
  }
});

const port = process.env.PORT || 8000;
app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
  console.log(`📊 Health check: http://localhost:${port}/health`);
  console.log(`🎬 Video rendering: POST http://localhost:${port}/render`);
  console.log(`📁 Media files: http://localhost:${port}/media/`);
  console.log(`📤 Upload file: POST http://localhost:${port}/upload`);
  console.log(`📤 Upload multiple: POST http://localhost:${port}/upload-multiple`);
  console.log(`📋 Clone media: POST http://localhost:${port}/clone-media`);
  console.log(`🗑️ Delete file: DELETE http://localhost:${port}/media/:filename`);
  console.log(`🖥️ Optimized for 4vCPU, 8GB RAM server:`);
  console.log(`   - Multi-threaded processing (3 cores)`);
  console.log(`   - Balanced quality/speed encoding`);
  console.log(`   - Full resolution rendering`);
  console.log(`   - 15-minute timeout for longer videos`);
  console.log(`📂 Media files are served from: ${path.resolve('out')}`);
});





================================================
FILE: backend/README.md
================================================
Here lies the glorious backend.

How to run:

```
uv sync
uv run main.py
```


================================================
FILE: backend/Dockerfile
================================================
FROM python:3.12-slim

RUN pip install uv

WORKDIR /app

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen

COPY . .

EXPOSE 3000

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]



================================================
FILE: backend/main.py
================================================
import os
from typing import Any

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google import genai
from pydantic import BaseModel, ConfigDict

from schema import FunctionCallResponse, MediaBinItem, TimelineState

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

app = FastAPI()
gemini_api = genai.Client(api_key=GEMINI_API_KEY)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Message(BaseModel):
    # Be permissive with incoming payloads from the frontend
    model_config = ConfigDict(extra="ignore")

    message: str  # the full user message
    mentioned_scrubber_ids: list[str] | None = None  # scrubber ids mentioned via '@'
    # Accept any shape for resilience; backend does not mutate these
    timeline_state: dict[str, Any] | None = None  # current timeline state
    mediabin_items: list[dict[str, Any]] | None = None  # current media bin
    chat_history: list[dict[str, Any]] | None = None  # prior turns: [{"role":"user"|"assistant","content":"..."}]


@app.post("/ai")
async def process_ai_message(request: Message) -> FunctionCallResponse:
    print(FunctionCallResponse)
    try:
        response = gemini_api.models.generate_content(
            model="gemini-2.5-flash",
            contents=f"""
            You are Kimu, an AI assistant inside a video editor. You can decide to either:
            - call ONE tool from the provided schema when the user explicitly asks for an editing action, or
            - return a short friendly assistant_message when no concrete action is needed (e.g., greetings, small talk, clarifying questions).

            Strictly follow:
            - If the user's message does not clearly request an editing action, set function_call to null and include an assistant_message.
            - Only produce a function_call when it is safe and unambiguous to execute.

            Inference rules:
            - Assume a single active timeline; do NOT require a timeline_id.
            - Tracks are named like "track-1", but when the user says "track 1" they mean number 1.
            - Use pixels_per_second=100 by default if not provided.
            - When the user names media like "twitter" or "twitter header", map that to the closest media in the media bin by name substring match.
            - Prefer LLMAddScrubberByName when the user specifies a name, track number, and time in seconds.
            - If the user asks to remove scrubbers in a specific track, call LLMDeleteScrubbersInTrack with that track number.

            Conversation so far (oldest first): {request.chat_history}

            User message: {request.message}
            Mentioned scrubber ids: {request.mentioned_scrubber_ids}
            Timeline state: {request.timeline_state}
            Media bin items: {request.mediabin_items}
            """,
            config={
                "response_mime_type": "application/json",
                "response_schema": FunctionCallResponse,
            },
        )
        print(response)

        return FunctionCallResponse.model_validate(response.parsed)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=3000)



================================================
FILE: backend/pyproject.toml
================================================
[project]
name = "backend"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
license = { file = "../LICENSE.md" }
classifiers = [
    "License :: OSI Approved :: GNU Affero General Public License v3",
]
requires-python = ">=3.12"
dependencies = [
    "fastapi[standard]>=0.115.13",
    "google-genai>=1.22.0",
    "mypy>=1.16.1",
    "ruff>=0.12.1",
]

[project.optional-dependencies]
dev = [
    "ruff>=0.3.0",
    "mypy>=1.8.0",
]

[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "B", "C4", "UP", "ARG", "SIM", "TCH", "TID", "Q"]
ignore = ["E501", "B008", "F401", "F841", "W293", "ARG001", "N815"]

[tool.mypy]
python_version = "3.12"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true



================================================
FILE: backend/schema.py
================================================
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class BaseSchema(BaseModel):
    # Ignore extra fields to stay compatible with richer frontend objects
    model_config = ConfigDict(extra="ignore")


class TextProperties(BaseSchema):
    textContent: str = Field(description="The text content to display")
    fontSize: int = Field(description="Font size in pixels")
    fontFamily: str = Field(description="Font family name")
    color: str = Field(description="Text color in hex format")
    textAlign: Literal["left", "center", "right"] = Field(description="Text alignment")
    fontWeight: Literal["normal", "bold"] = Field(description="Font weight")


class BaseScrubber(BaseSchema):
    id: str = Field(description="Unique identifier for the scrubber")
    mediaType: Literal["video", "image", "audio", "text"] = Field(description="Type of media")
    mediaUrlLocal: str | None = Field(description="Local URL for the media file", default=None)
    mediaUrlRemote: str | None = Field(description="Remote URL for the media file", default=None)
    media_width: int = Field(description="Width of the media in pixels")
    media_height: int = Field(description="Height of the media in pixels")
    text: TextProperties | None = Field(description="Text properties if mediaType is text", default=None)


class MediaBinItem(BaseScrubber):
    name: str = Field(description="Display name for the media item")
    durationInSeconds: float = Field(description="Duration of the media in seconds")


class ScrubberState(MediaBinItem):
    left: int = Field(description="Left position in pixels on the timeline")
    y: int = Field(description="Track position (0-based index)")
    width: int = Field(description="Width of the scrubber in pixels")
    
    # Player properties
    left_player: int = Field(description="Left position in the player view")
    top_player: int = Field(description="Top position in the player view")
    width_player: int = Field(description="Width in the player view")
    height_player: int = Field(description="Height in the player view")
    is_dragging: bool = Field(description="Whether the scrubber is currently being dragged")


class TrackState(BaseSchema):
    id: str = Field(description="Unique identifier for the track")
    scrubbers: list[ScrubberState] = Field(description="List of scrubbers on this track")


class TimelineState(BaseSchema):
    tracks: list[TrackState] = Field(description="List of tracks in the timeline")


class LLMAddScrubberToTimelineArgs(BaseSchema):
    function_name: Literal["LLMAddScrubberToTimeline"] = Field(
        description="The name of the function to call"
    )
    scrubber_id: str = Field(
        description="The id of the scrubber to add to the timeline"
    )
    track_id: str = Field(description="The id of the track to add the scrubber to")
    drop_left_px: int = Field(description="The left position of the scrubber in pixels")


class LLMMoveScrubberArgs(BaseSchema):
    function_name: Literal["LLMMoveScrubber"] = Field(
        description="The name of the function to call"
    )
    scrubber_id: str = Field(description="The id of the scrubber to move")
    new_position_seconds: float = Field(
        description="The new position of the scrubber in seconds"
    )
    new_track_number: int = Field(description="The new track number of the scrubber")
    pixels_per_second: int = Field(description="The number of pixels per second")


class LLMAddScrubberByNameArgs(BaseSchema):
    function_name: Literal["LLMAddScrubberByName"] = Field(
        description="The name of the function to call"
    )
    scrubber_name: str = Field(description="The partial or full name of the media to add")
    track_number: int = Field(description="1-based track number to add to")
    position_seconds: float = Field(description="Timeline time in seconds to place the media at")
    pixels_per_second: int = Field(description="Pixels per second to convert time to pixels")


class LLMDeleteScrubbersInTrackArgs(BaseSchema):
    function_name: Literal["LLMDeleteScrubbersInTrack"] = Field(
        description="The name of the function to call"
    )
    track_number: int = Field(description="1-based track number whose scrubbers will be removed")


class FunctionCallResponse(BaseSchema):
    function_call: LLMAddScrubberToTimelineArgs | LLMMoveScrubberArgs | LLMAddScrubberByNameArgs | LLMDeleteScrubbersInTrackArgs | None = None
    assistant_message: str | None = None



================================================
FILE: backend/.env.example
================================================
GEMINI_API_KEY=""


================================================
FILE: backend/.python-version
================================================
3.12



================================================
FILE: migrations/000_init.sql
================================================
-- 000_init.sql - initial auth tables

-- Users table
create table if not exists "user" (
  id text primary key,
  name text null,
  email text unique not null,
  emailVerified boolean default false not null,
  image text null,
  createdAt timestamptz not null default now(),
  updatedAt timestamptz not null default now()
);

-- Sessions table
create table if not exists session (
  id text primary key,
  expiresAt timestamptz not null,
  token text unique not null,
  createdAt timestamptz not null default now(),
  updatedAt timestamptz not null default now(),
  ipAddress text null,
  userAgent text null,
  userId text not null references "user"(id) on delete cascade
);
create index if not exists idx_session_userId on session(userId);
create index if not exists idx_session_token on session(token);

-- Accounts table
create table if not exists account (
  id text primary key,
  accountId text null,
  providerId text null,
  userId text not null references "user"(id) on delete cascade,
  accessToken text null,
  refreshToken text null,
  idToken text null,
  accessTokenExpiresAt timestamptz null,
  refreshTokenExpiresAt timestamptz null,
  scope text null,
  password text null,
  createdAt timestamptz not null default now(),
  updatedAt timestamptz not null default now()
);
create index if not exists idx_account_userId on account(userId);

-- Verification table
create table if not exists verification (
  id text primary key,
  identifier text not null,
  value text not null,
  expiresAt timestamptz not null,
  createdAt timestamptz not null default now(),
  updatedAt timestamptz not null default now()
);

-- Trigger to auto-update updatedAt fields (Postgres example)
do $$
begin
  if not exists (select 1 from pg_proc where proname = 'set_updated_at') then
    create function set_updated_at() returns trigger as $$
    begin
      new."updatedAt" = now();
      return new;
    end;
    $$ language plpgsql;
  end if;
end$$;

-- Attach triggers where appropriate
do $$ begin
  if not exists (select 1 from pg_trigger where tgname='trg_user_updated_at') then
    create trigger trg_user_updated_at before update on "user"
    for each row execute function set_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname='trg_session_updated_at') then
    create trigger trg_session_updated_at before update on session
    for each row execute function set_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname='trg_account_updated_at') then
    create trigger trg_account_updated_at before update on account
    for each row execute function set_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname='trg_verification_updated_at') then
    create trigger trg_verification_updated_at before update on verification
    for each row execute function set_updated_at();
  end if;
end $$;





================================================
FILE: migrations/001_assets.sql
================================================
-- Consolidated migration: assets table with project support
create table if not exists assets (
  id uuid primary key,
  user_id text not null,
  original_name text not null,
  storage_key text not null,
  mime_type text not null,
  size_bytes bigint not null,
  width int null,
  height int null,
  duration_seconds double precision null,
  created_at timestamptz not null default now(),
  deleted_at timestamptz null
);

-- Ensure columns for evolving installs
alter table assets add column if not exists project_id text null;

-- Ensure user_id has type text (for older installs)
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_name = 'assets' and column_name = 'user_id' and data_type <> 'text'
  ) then
    execute 'alter table assets alter column user_id type text using user_id::text';
  end if;
exception when others then
  null;
end $$;

create index if not exists idx_assets_user_id_created_at on assets(user_id, created_at desc);
create index if not exists idx_assets_user_project on assets(user_id, project_id, created_at desc);
create unique index if not exists idx_assets_user_storage_key on assets(user_id, storage_key);





================================================
FILE: migrations/002_projects.sql
================================================
-- Minimal projects table to support asset scoping later
create table if not exists projects (
  id uuid primary key,
  user_id text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_projects_user_id_created_at on projects(user_id, created_at desc);





================================================
FILE: .github/PULL_REQUEST_TEMPLATE.md
================================================
## Summary
<!--Briefly explain the purpose of this PR and the user impact.-->

## Changes
- What changed at a high level?
- Any notable design/architecture decisions?

## Testing
<!--Testing done to ensure it works as intended-->

## Screenshots / Recordings (if UI)
<!--Attach images or short videos/GIFs showcasing changes. -->

## Related Issues
<!-- Link to any relevant issues. Use "Closes #<issue_number>" to automatically close an issue when this PR is merged. -->
Closes #
Refs #

## Breaking Changes
<!--Describe any breaking behavior and required follow-up actions.-->

## Deployment Notes
<!--Mention any infra/config changes (Dockerfiles, docker-compose, Nginx, env vars).-->



================================================
FILE: .github/workflows/lint.yml
================================================
name: Lint and Typecheck

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]

jobs:
  frontend:
    name: Frontend ESLint and TS
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v4
        with:
          version: 9
          run_install: false

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "lts/*"
          cache: "pnpm"

      - name: Install deps
        run: pnpm install --frozen-lockfile

      - name: Generate router types & TS typecheck (tsc)
        run: pnpm run typecheck --noEmit

      - name: ESLint
        run: pnpm eslint . --ext .ts,.tsx --fix

      - name: Prettier format (auto-fix)
        run: pnpm format

  backend:
    name: Backend Ruff and mypy
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python (uv)
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true
          python-version: "3.12"

      - name: Install deps (with dev extras)
        run: uv sync --extra dev --dev

      - name: Ruff check
        run: uv run python -m ruff check .

      - name: Ruff format (auto-fix)
        run: uv run python -m ruff format .

      - name: mypy
        run: uv run mypy .


