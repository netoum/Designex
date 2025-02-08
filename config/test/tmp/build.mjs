import { register as registerTokenStudio } from '@tokens-studio/sd-transforms';
import { makeSdTailwindConfig } from 'sd-tailwindcss-transformer'
import StyleDictionary from 'style-dictionary';
import { transformTokens } from './transform.mjs';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'url';

await transformTokens();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const base = path.resolve(__dirname)

const modes = ['dark']
const types = ['colors', 'borderRadius', 'fontFamily'];
const sets = JSON.parse(fs.readFileSync(path.resolve(base, 'tokens/multi/$metadata.json'), 'utf-8')).tokenSetOrder;

registerTokenStudio(StyleDictionary, {
  excludeParentKeys: false,
  platform: "css",
  'ts/color/modifiers': {
    format: 'hsl',
  }
});

const allPromises = [
  ...types.map((type) =>
    sets.map((set) => {
      const Tailwind = new StyleDictionary(
        makeSdTailwindConfig({
          type,
          preprocessors: ['tokens-studio'],
          isVariables: true,
          source: [`${base}/tokens/multi/${set}.json`],
        })
      )
      Tailwind.platforms[`tailwind/${type}`] = {
        transforms: ['attribute/cti', 'name/kebab', 'ts/descriptionToComment', 'ts/resolveMath', 'ts/size/px', 'ts/opacity', 'ts/size/lineheight', 'ts/typography/fontWeight', 'ts/color/modifiers', 'ts/size/css/letterspacing', 'ts/shadow/innerShadow'],
        buildPath: `${base}/build/${set}/`,
        files: [
          {
            destination: `${type}.js`,
            format: 'tailwindFormat',
            options: {
              outputReferences: true,
            },
            filter: async (token) => {
              return token.path[0] == type && token.filePath.endsWith(`${set}.json`);
            }
          }
        ]
      }
      Tailwind['log'] = { verbosity: 'default' }
      return Tailwind.buildAllPlatforms();
    })
  ),

  ...sets.map((set) => {
    const CSS = new StyleDictionary(
      makeSdTailwindConfig({
        type: 'all',
        preprocessors: ['tokens-studio'],
        isVariables: true,
        source: [`${base}/tokens/multi/${set}.json`],
      })
    )
    CSS.platforms['css'] = {
      transforms: ['attribute/cti', 'name/kebab', 'ts/descriptionToComment', 'ts/resolveMath', 'ts/size/px', 'ts/opacity', 'ts/size/lineheight', 'ts/typography/fontWeight', 'ts/color/modifiers', 'ts/size/css/letterspacing', 'ts/shadow/innerShadow'],
      buildPath: `${base}/build/css/`,
      files: [
        {
          destination: `${set}.css`,
          format: 'css/variables',
          options: {
            outputReferences: false,
          }
        },
      ],
    };
    CSS['log'] = { verbosity: 'default' }
    return CSS.buildPlatform('css');
  }),

  ...modes.map((mode) => {
    const CSSMode = new StyleDictionary(
      makeSdTailwindConfig({
        type: 'all',
        preprocessors: ['tokens-studio'],
        isVariables: true,
        source: [`${base}/tokens/multi/mode/${mode}.json`],
      })
    )
    CSSMode.platforms['css'] = {
      transforms: ['attribute/cti', 'name/kebab', 'ts/descriptionToComment', 'ts/resolveMath', 'ts/size/px', 'ts/opacity', 'ts/size/lineheight', 'ts/typography/fontWeight', 'ts/color/modifiers', 'ts/size/css/letterspacing', 'ts/shadow/innerShadow'],
      buildPath: `${base}/build/css/mode/`,
      files: [
        {
          destination: `${mode}.css`,
          format: 'css/variables',
          options: {
            outputReferences: false,
            selector: `.${mode}`
          }
        },
      ],
    };
    CSSMode['log'] = { verbosity: 'default' }
    return CSSMode.buildPlatform('css');
  })
];

Promise.all(allPromises)
  .then(() => console.log('✅ Build completed successfully'))
  .catch(error => console.error('❌ Build failed:', error));
