import { type AnyModel, isModelType, type Model, type Provider, type RefreshModelsContext } from "generation-ai";

/** Personalize a provider's native static catalog using provider-specific metadata. */
export type PersonalizeCatalog = (
	catalog: readonly AnyModel[],
	context: RefreshModelsContext,
) => Promise<readonly AnyModel[]>;

export function withPersonalizedCatalog(provider: Provider, personalize: PersonalizeCatalog): Provider {
	let personalModels: readonly AnyModel[] = [];
	const builtinModels = (): readonly AnyModel[] => provider.getAllModels?.() ?? provider.getModels();
	const getAllModels = (): readonly AnyModel[] => (personalModels.length > 0 ? personalModels : builtinModels());

	return {
		...provider,
		getModels: () =>
			(personalModels.length > 0
				? personalModels.filter((model): model is Model<any> => isModelType(model, "chat"))
				: provider.getModels()) as ReturnType<typeof provider.getModels>,
		getAllModels,
		refreshModels: async (context) => {
			const restored = (context.stored?.models ?? []).filter((model) => model.provider === provider.id);
			if (!(await context.publish({ update: () => { personalModels = restored; } }))) return;
			if (!context.allowNetwork || context.signal.aborted) return;

			const personalized = await personalize(builtinModels(), context);
			if (context.signal.aborted) return;
			await context.publish({
				persist: { models: personalized, checkedAt: Date.now() },
				update: () => { personalModels = personalized; },
			});
		},
	};
}
